import {
  Catch,
  ArgumentsHost,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';
import Crypto from '../crypto/crypto';

@Catch()
export class EncryptExceptionFilter implements ExceptionFilter {
  catch(exception: any, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    response.setHeader(
      'Strict-Transport-Security',
      'max-age=31536000; includeSubDomains; preload',
    );

    const originalStatus =
      exception instanceof HttpException
        ? exception.getStatus()
        : exception?.response?.status || HttpStatus.INTERNAL_SERVER_ERROR;

    const statusMap: Record<number, number> = {
      [HttpStatus.NO_CONTENT]: HttpStatus.NO_CONTENT,
      [HttpStatus.PARTIAL_CONTENT]: HttpStatus.PARTIAL_CONTENT,
      [HttpStatus.NOT_FOUND]: HttpStatus.NO_CONTENT,
      [HttpStatus.UNAUTHORIZED]: HttpStatus.UNAUTHORIZED,
    };

    const finalStatus = statusMap[originalStatus] ?? originalStatus;

    const originalData =
      exception?.response?.data ??
      (exception instanceof HttpException
        ? exception.getResponse()
        : { message: 'Internal Server Error' });

    const safeData =
      typeof originalData === 'string'
        ? { message: originalData }
        : originalData;

    const encryptedError = Crypto.encrypt(
      JSON.stringify(safeData),
      process.env.APPENCRYPTKEYTWO,
    );

    response.status(finalStatus).json({ response: encryptedError });
  }
}
