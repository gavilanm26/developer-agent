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
    let headers: any;
    let path: string;

    if (context.getType() === 'http') {
      const request = context.switchToHttp().getRequest();
      headers = request.headers;
      path = request.path;
    } 
    // <<GQL
    else {
      const gqlCtx = (context as any).getArgs()[2];
      headers = gqlCtx?.req?.headers;
      path = gqlCtx?.req?.path;
    }
    // GQL>>

    if (!headers || !path) return next.handle();

    const lowerCaseHeaders = this.requiredHeaders.map((h) => h.toLowerCase());

    const isHealthPath = path.startsWith('/health');
    let isGraphqlPath = false;
    // <<GQL
    isGraphqlPath = path.startsWith('/graphql');
    // GQL>>

    if (!isHealthPath && !isGraphqlPath) {
      for (const header of lowerCaseHeaders) {
        if (!headers[header]) {
          throw new HttpException(
            `Missing required header: ${header}`,
            HttpStatus.BAD_REQUEST,
          );
        }
      }
    }

    return next.handle();
  }
}
