import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import type { Request } from 'express';
import { Observable } from 'rxjs';

@Injectable()
export class HeadersInterceptor implements NestInterceptor {
  private readonly requiredHeaders: string[];
  public constructor(requiredHeaders: string[]) {
    this.requiredHeaders = requiredHeaders;
  }

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const request = context.switchToHttp().getRequest<Request>();

    const lowerCaseHeaders = this.requiredHeaders.map((requiredHeader) =>
      requiredHeader.toLowerCase(),
    );

    for (const header of lowerCaseHeaders) {
      if (!request.headers[header]) {
        throw new HttpException(
          `Missing required header: ${header}`,
          HttpStatus.BAD_REQUEST,
        );
      }
    }

    return next.handle();
  }
}
