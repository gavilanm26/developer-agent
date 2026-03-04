import { AxiosError } from 'axios';
import { HttpException, Logger, NotFoundException } from '@nestjs/common';
import { catchError, tap, map } from 'rxjs/operators';
import { MonoTypeOperatorFunction, Observable, OperatorFunction, throwError } from 'rxjs';

const formatHeaders = (headers?: any) => {
  return headers
    ? Object.entries(headers)
        .map(([k, v]) => {
          if (k.toLowerCase() === 'authorization') {
            return `${k}:Bearer ***`;
          }
          return `${k}:${v}`;
        })
        .join(', ')
    : undefined;
};

const formatRequest = (request?: any) => {
  return request ? Buffer.from(JSON.stringify(request), 'utf8').toString('base64') : undefined;
};

export function httpLogger(
  logger: Logger,
  responseShow?: boolean,
  processId?: any,
  document?: any,
  request?: any,
  headers?: any,
  url?: string,
) {
  return (source$: {
    pipe: (
      arg0: MonoTypeOperatorFunction<any>,
      arg1: OperatorFunction<unknown, unknown>,
    ) => any;
  }) =>
    source$.pipe(
      tap((response: any) => {
        const logData = {
          code: response.status,
          processId: processId,
          document: document,
          url: url,
          headers: formatHeaders(headers),
          request: formatRequest(request),
          response:
            responseShow === true
              ? Buffer.from(JSON.stringify(response.data), 'utf8').toString('base64')
              : undefined,
        };

        if (response.status >= 200 && response.status < 300) {
          logger.log(logData);
        } else if (response.status >= 300 && response.status < 400) {
          logger.verbose(logData);
        } else {
          logger.warn(logData);
        }
      }),
      catchError((error: AxiosError) => {
        const statusCode = error.response?.status;
        const errorResponse = error.response?.data
          ? error.response.data
          : error.message || 'Unexpected Error';

        const logData = {
          code: statusCode,
          processId: processId,
          document: document,
          url: url,
          headers: formatHeaders(headers),
          request: formatRequest(request),
          response: errorResponse,
        };

        if (statusCode && statusCode >= 400 && statusCode < 500) {
          logger.warn(logData);
        } else {
          logger.error(logData);
        }

        throw new HttpException(
          error.response?.data || error.message || 'Unexpected Error',
          Number(statusCode ?? 503),
        );
      }),
    );
}

export function internalLogger(
  logger: Logger,
  responseShow?: boolean,
  processId?: any,
  document?: any,
  request?: any,
  headers?: any,
  operation?: string,
) {
  return (source$: Observable<any>): Observable<any> =>
    source$.pipe(
      map((res: any) => {
        const isEmpty = !res.result || (typeof res.result === 'object' && Object.keys(res.result).length === 0);

        if (isEmpty) {
          throw new NotFoundException('No se obtuvo resultado de la evaluación de reglas');
        }

        return { ...res, data: res.result, status: 200 };
      }),
      tap((response: any) => {
        logger.log({
          code: response.status,
          processId: processId,
          document: document,
          operation: operation,
          headers: formatHeaders(headers),
          request: formatRequest(request),
          response:
            responseShow === true
              ? Buffer.from(JSON.stringify(response.data), 'utf8').toString('base64')
              : undefined,
        });
      }),
      catchError((error: any) => {
        const isHttpException = error instanceof HttpException;

        let statusCode = 503;
        let errorResponse = error.message || 'Unexpected Error';

        if (isHttpException) {
          statusCode = error.getStatus();
          errorResponse = error.getResponse();
        }

        const logData = {
          code: statusCode,
          processId: processId,
          document: document,
          operation: operation,
          headers: formatHeaders(headers),
          request: formatRequest(request),
          response: errorResponse,
        };

        if (statusCode >= 400 && statusCode < 500) {
          logger.warn(logData);
        } else {
          logger.error(logData);
        }

        return throwError(() => error);
      }),
      map((res: any) => res.data),
    );
}
