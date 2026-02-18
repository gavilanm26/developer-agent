import { AxiosError } from 'axios';
import { HttpException, Logger } from '@nestjs/common';
import { catchError, tap } from 'rxjs/operators';
import { MonoTypeOperatorFunction, OperatorFunction } from 'rxjs';

export function httpLogger(
  logger: Logger,
  responseShow?: boolean,
  processId?: any,
  document?: any,
  request?: any,
  headers?: any,
) {
  return (source$: {
    pipe: (
      arg0: MonoTypeOperatorFunction<any>,
      arg1: OperatorFunction<unknown, unknown>,
    ) => any;
  }) =>
    source$.pipe(
      tap((response: any) => {
        logger.verbose({
          code: response.status,
          processId: processId,
          document: document,
          response:
            responseShow === true
              ? btoa(JSON.stringify(response.data))
              : undefined,
          request: request ? btoa(JSON.stringify(request)) : undefined,
          headers: headers,
        });
      }),
      catchError((error: AxiosError) => {
        logger.error({
          code: error.response?.status,
          processId: processId,
          document: document,
          response: error.response?.data
            ? error.response.data
            : error.message || 'Unexpected Error',
          request: request ? btoa(JSON.stringify(request)) : undefined,
          headers: headers,
        });
        throw new HttpException(
          error.response?.data || error.message || 'Unexpected Error',
          Number(error.response?.status || 503),
        );
      }),
    );
}
