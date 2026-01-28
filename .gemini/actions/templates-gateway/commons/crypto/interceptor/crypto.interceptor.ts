import { CallHandler, ExecutionContext, NestInterceptor } from '@nestjs/common';
import { Observable } from 'rxjs';
import Crypto from '../crypto';
import { map } from 'rxjs/operators';
import { GqlExecutionContext } from '@nestjs/graphql';

export class CryptoRequestInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();

    if (request?.body?.data) {
      const decrypt = Crypto.decrypt(request.body.data);
      try {
        request.body.data = JSON.parse(decrypt);
      } catch (error) {
        request.body.data = decrypt;
      }
    }

    return next.handle();
  }
}

export class CryptoResponseInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    return next.handle().pipe(
      map((data) => {
        if (
          !request?.url.startsWith('/health') &&
          !request?.url.startsWith('/graphql') &&
          !request?.url.startsWith('/reports')
        )
          if (data !== undefined && data !== null) {
            const encrypt = Crypto.encrypt(data);
            return { response: encrypt };
          }
        return data;
      }),
    );
  }
}

export class CryptoRequestGraphqlInterceptor implements NestInterceptor {
  intercept(
    context: ExecutionContext,
    next: CallHandler,
    gqlContext: GqlExecutionContext = GqlExecutionContext.create(context),
  ): Observable<any> {
    const info = gqlContext.getInfo();
    const args = gqlContext.getArgs();

    if (info.fieldName && args.data) {
      const decrypt = Crypto.decrypt(args.data);
      try {
        args.data = JSON.parse(decrypt);
      } catch (error) {
        args.data = decrypt;
      }
    }

    return next.handle();
  }
}
