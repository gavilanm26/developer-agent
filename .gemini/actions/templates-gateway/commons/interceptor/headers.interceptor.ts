import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { GqlExecutionContext } from '@nestjs/graphql';

@Injectable()
export class HeadersInterceptor implements NestInterceptor {
  private readonly requiredHeaders: string[];

  public constructor(requiredHeaders: string[]) {
    this.requiredHeaders = requiredHeaders;
  }

  intercept(
    context: ExecutionContext,
    next: CallHandler,
    gqlContext: GqlExecutionContext = GqlExecutionContext.create(context),
  ): Observable<any> {
    const ctx = gqlContext.getContext();
    const headers = ctx.req.headers;
    const path = ctx.req.path;

    const lowerCaseHeaders = this.requiredHeaders.map((requiredHeaders) =>
      requiredHeaders.toLowerCase(),
    );

    if (!path.startsWith('/health') && !path.startsWith('/graphql'))
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
