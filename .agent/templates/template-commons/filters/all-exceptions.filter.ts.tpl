import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { IntegrationException } from '@commons/exceptions/integration.exception';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: any, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Unexpected error';

    if (exception instanceof IntegrationException) {
      status = exception.getStatus();
      message = exception.message;
    } else if (
      exception?.isAxiosError ||
      exception?.code === 'ECONNRESET' ||
      exception?.code === 'ETIMEDOUT' ||
      exception?.code === 'ENOTFOUND'
    ) {
      status = HttpStatus.BAD_GATEWAY;
      const axiosMessage =
        exception?.response?.data?.message || exception.message;
      message = 'Upstream integration failure';
      this.logger.error(
        `Integration failure [${exception.code || 'HTTP'}]: ${axiosMessage}`,
        exception?.stack,
      );
    } else if (exception instanceof HttpException) {
      status = exception.getStatus();
      const resBody: any = exception.getResponse();

      if (typeof resBody === 'string') {
        const parsed = this.tryParseJsonMessage(resBody);
        message = parsed ?? resBody;
      } else if (resBody && typeof resBody === 'object') {
        message =
          resBody.response?.responseDetail?.errorDesc ||
          resBody.responseDetail?.errorDesc ||
          (Array.isArray(resBody.message)
            ? resBody.message.join(', ')
            : resBody.message) ||
          resBody.errorDesc ||
          resBody.error ||
          exception.message;
      } else {
        message = exception.message;
      }
      if (status === HttpStatus.NO_CONTENT) {
        this.logger.warn(`${HttpStatus.NO_CONTENT}: ${message}`);
        return response
          .setHeader(
            'Strict-Transport-Security',
            'max-age=31536000; includeSubDomains; preload',
          )
          .status(HttpStatus.NO_CONTENT)
          .send();
      }
    } else {
      this.logger.error(
        `Unhandled error: ${exception?.message || exception}`,
        exception?.stack,
      );
    }

    if (status === HttpStatus.INTERNAL_SERVER_ERROR) {
      status = HttpStatus.BAD_GATEWAY;
      message = 'Integration error - check logs for details';
    }

    response
      .setHeader(
        'Strict-Transport-Security',
        'max-age=31536000; includeSubDomains; preload',
      )
      .status(status)
      .json({
        message,
      });
  }

  private tryParseJsonMessage(raw: string): string | null {
    try {
      const parsed = JSON.parse(raw) as {
        message?: string | string[];
        error?: string;
        errorDesc?: string;
      };
      if (Array.isArray(parsed.message)) {
        return parsed.message.join(', ');
      }
      if (typeof parsed.message === 'string') {
        return parsed.message;
      }
      if (typeof parsed.errorDesc === 'string') {
        return parsed.errorDesc;
      }
      if (typeof parsed.error === 'string') {
        return parsed.error;
      }
      return null;
    } catch {
      return null;
    }
  }
}
