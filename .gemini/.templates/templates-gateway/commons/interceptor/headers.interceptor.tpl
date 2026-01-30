import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Observable } from 'rxjs';

@Injectable()
export class HeadersInterceptor implements NestInterceptor {
  private readonly requiredHeaders: string[];

  public constructor(requiredHeaders: string[]) {
    this.requiredHeaders = requiredHeaders;
  }

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const headers = request.headers;
    const path = request.path;

    const lowerCaseHeaders = this.requiredHeaders.map((requiredHeaders) =>
      requiredHeaders.toLowerCase(),
    );

    if (!path.startsWith('/health'))
      for (const header of lowerCaseHeaders) {
        if (!headers[header]) {
          throw new HttpException(
            `Missing required header: ${header}`,
            HttpStatus.BAD_REQUEST,
          );
        }
      }

    return next.handle();
  }
}
