import { Test } from '@nestjs/testing';
import { Logger } from '@nestjs/common';
import { of, throwError } from 'rxjs';
import { AxiosError } from 'axios';
import { httpLogger } from '@commons/http-logger/httpLogger';

describe('httpLogger', () => {
  let logger: Logger;

  beforeEach(async () => {
    const moduleRef = await Test.createTestingModule({
      providers: [Logger],
    }).compile();

    logger = moduleRef.get<Logger>(Logger);
  });

  it('should log with logger.log() on successful response (200)', () => {
    jest.spyOn(logger, 'log').mockImplementation(() => { });

    const response = {
      status: 200,
      data: { message: 'Success' },
    };

    const source$ = of(response);
    const logSpy = jest.spyOn(logger, 'log');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe();

    expect(logSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        code: 200,
        document: undefined,
        headers: undefined,
        processId: undefined,
        request: undefined,
        response: undefined,
      }),
    );
  });

  it('should log with logger.warn() on 404 error', (done) => {
    const errorResponse = {
      status: 404,
      data: { message: 'Not Found' },
    };

    const error = new AxiosError(
      'Not Found',
      'ERR',
      {} as any,
      undefined,
      errorResponse as any,
    ) as any;

    error.response = errorResponse;

    jest.spyOn(logger, 'warn').mockImplementation(() => { });

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'warn');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => { },
      error: () => {
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 404,
          }),
        );
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should not log response data when responseShow is false', () => {
    jest.spyOn(logger, 'log').mockImplementation(() => { });

    const response = {
      status: 200,
      data: { message: 'Success' },
    };

    const source$ = of(response);
    const logSpy = jest.spyOn(logger, 'log');

    httpLogger(
      logger,
      false,
    )({
      pipe: source$.pipe.bind(source$),
    }).subscribe();

    expect(logSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        code: 200,
        response: undefined,
      }),
    );
  });

  it('should log with logger.warn() and use default message when error data is missing (404)', (done) => {
    const errorResponse = {
      status: 404,
    };

    const error = new AxiosError(
      'Error with no data',
      'ERR',
      {} as any,
      undefined,
      errorResponse as any,
    ) as any;

    error.response = errorResponse;

    jest.spyOn(logger, 'warn').mockImplementation(() => { });

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'warn');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => { },
      error: () => {
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 404,
            response: 'Error with no data',
          }),
        );
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should handle null or undefined parameters and default values', () => {
    jest.spyOn(logger, 'log').mockImplementation(() => { });

    const response = {
      status: 200,
      data: { message: 'Success' },
    };

    const source$ = of(response);
    const logSpy = jest.spyOn(logger, 'log');

    httpLogger(
      logger,
      true,
      null,
      null,
      null,
      null,
    )({
      pipe: source$.pipe.bind(source$),
    }).subscribe();

    expect(logSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        code: 200,
        response: btoa(JSON.stringify({ message: 'Success' })),
      }),
    );
  });

  it('should log with logger.error() on network errors without response', (done) => {
    const error = new AxiosError(
      'Network Failure',
      'NET_ERR',
      {} as any,
      undefined,
      undefined,
    );

    jest.spyOn(logger, 'error').mockImplementation(() => { });

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'error');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => { },
      error: () => {
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: undefined,
            response: 'Network Failure',
          }),
        );
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should log with logger.error() on 500 errors', (done) => {
    const errorResponse = {
      status: 500,
      data: { message: 'Server error' },
    };

    const error = new AxiosError(
      undefined,
      'ERR',
      {} as any,
      undefined,
      errorResponse as any,
    );

    jest.spyOn(logger, 'error').mockImplementation(() => { });

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'error');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => { },
      error: () => {
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 500,
            response: { message: 'Server error' },
          }),
        );
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should log with logger.warn() and use error.message when error.response.data is null (400)', (done) => {
    const errorResponse = {
      status: 400,
      data: null,
    };

    const error = new AxiosError(
      'Bad Request Error',
      'ERR',
      {} as any,
      undefined,
      errorResponse as any,
    );

    jest.spyOn(logger, 'warn').mockImplementation(() => { });

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'warn');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => { },
      error: () => {
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 400,
            response: 'Bad Request Error',
          }),
        );
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should log with logger.error() and use error.message when error.response.data is undefined (500)', (done) => {
    const errorResponse = {
      status: 500,
      data: undefined,
    };

    const error = new AxiosError(
      'Server Error Message',
      'ERR',
      {} as any,
      undefined,
      errorResponse as any,
    );

    jest.spyOn(logger, 'error').mockImplementation(() => { });

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'error');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => { },
      error: () => {
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 500,
            response: 'Server Error Message',
          }),
        );
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should log with logger.error() when both error.response.data and error.message are falsy (503)', (done) => {
    const errorResponse = {
      status: 503,
      data: null,
    };

    const error = new AxiosError(
      '',
      'ERR',
      {} as any,
      undefined,
      errorResponse as any,
    );

    jest.spyOn(logger, 'error').mockImplementation(() => { });

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'error');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => { },
      error: () => {
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 503,
            response: 'Unexpected Error',
          }),
        );
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should log with logger.warn() when error.response.data is false (400)', (done) => {
    const errorResponse = {
      status: 400,
      data: false,
    };

    const error = new AxiosError(
      '',
      'ERR',
      {} as any,
      undefined,
      errorResponse as any,
    );

    jest.spyOn(logger, 'warn').mockImplementation(() => { });

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'warn');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => { },
      error: () => {
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 400,
            response: 'Unexpected Error',
          }),
        );
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should set request to undefined when request parameter is falsy', () => {
    jest.spyOn(logger, 'log').mockImplementation(() => { });

    const response = {
      status: 200,
      data: { message: 'Success' },
    };

    const source$ = of(response);
    const logSpy = jest.spyOn(logger, 'log');

    httpLogger(
      logger,
      true,
      'process123',
      'doc123',
      null,
      { 'content-type': 'application/json' },
      'https://api.example.com',
    )({
      pipe: source$.pipe.bind(source$),
    }).subscribe();

    expect(logSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        code: 200,
        processId: 'process123',
        document: 'doc123',
        request: undefined,
        headers: 'content-type:application/json',
        url: 'https://api.example.com',
      }),
    );
  });

  it('should set request to undefined when request parameter is undefined', () => {
    jest.spyOn(logger, 'log').mockImplementation(() => { });

    const response = {
      status: 200,
      data: { message: 'Success' },
    };

    const source$ = of(response);
    const logSpy = jest.spyOn(logger, 'log');

    httpLogger(
      logger,
      true,
      'process123',
      'doc123',
      undefined,
      { 'content-type': 'application/json' },
      'https://api.example.com',
    )({
      pipe: source$.pipe.bind(source$),
    }).subscribe();

    expect(logSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        code: 200,
        processId: 'process123',
        document: 'doc123',
        request: undefined,
        headers: 'content-type:application/json',
        url: 'https://api.example.com',
      }),
    );
  });

  it('should set request to undefined when request parameter is empty string', () => {
    jest.spyOn(logger, 'log').mockImplementation(() => { });

    const response = {
      status: 200,
      data: { message: 'Success' },
    };

    const source$ = of(response);
    const logSpy = jest.spyOn(logger, 'log');

    httpLogger(
      logger,
      true,
      'process123',
      'doc123',
      '',
      { 'content-type': 'application/json' },
      'https://api.example.com',
    )({
      pipe: source$.pipe.bind(source$),
    }).subscribe();

    expect(logSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        code: 200,
        processId: 'process123',
        document: 'doc123',
        request: undefined,
        headers: 'content-type:application/json',
        url: 'https://api.example.com',
      }),
    );
  });

  it('should set request to undefined in error case when request parameter is null (500)', (done) => {
    const errorResponse = {
      status: 500,
      data: { message: 'Server error' },
    };

    const error = new AxiosError(
      'Server Error',
      'ERR',
      {} as any,
      undefined,
      errorResponse as any,
    );

    jest.spyOn(logger, 'error').mockImplementation(() => { });

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'error');

    httpLogger(
      logger,
      true,
      'process123',
      'doc123',
      null,
      { 'content-type': 'application/json' },
      'https://api.example.com',
    )({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => { },
      error: () => {
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 500,
            processId: 'process123',
            document: 'doc123',
            request: undefined,
            headers: 'content-type:application/json',
            url: 'https://api.example.com',
          }),
        );
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should set request to undefined in error case when request parameter is undefined (404)', (done) => {
    const errorResponse = {
      status: 404,
      data: { message: 'Not found' },
    };

    const error = new AxiosError(
      'Not Found',
      'ERR',
      {} as any,
      undefined,
      errorResponse as any,
    );

    jest.spyOn(logger, 'warn').mockImplementation(() => { });

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'warn');

    httpLogger(
      logger,
      true,
      'process123',
      'doc123',
      undefined,
      { 'content-type': 'application/json' },
      'https://api.example.com',
    )({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => { },
      error: () => {
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 404,
            processId: 'process123',
            document: 'doc123',
            request: undefined,
            headers: 'content-type:application/json',
            url: 'https://api.example.com',
          }),
        );
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should set request to undefined in error case when request parameter is empty string (400)', (done) => {
    const errorResponse = {
      status: 400,
      data: { message: 'Bad request' },
    };

    const error = new AxiosError(
      'Bad Request',
      'ERR',
      {} as any,
      undefined,
      errorResponse as any,
    );

    jest.spyOn(logger, 'warn').mockImplementation(() => { });

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'warn');

    httpLogger(
      logger,
      true,
      'process123',
      'doc123',
      '',
      { 'content-type': 'application/json' },
      'https://api.example.com',
    )({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => { },
      error: () => {
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 400,
            processId: 'process123',
            document: 'doc123',
            request: undefined,
            headers: 'content-type:application/json',
            url: 'https://api.example.com',
          }),
        );
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should encode request when request parameter is truthy in error case (500)', (done) => {
    const errorResponse = {
      status: 500,
      data: { message: 'Server error' },
    };

    const error = new AxiosError(
      'Server Error',
      'ERR',
      {} as any,
      undefined,
      errorResponse as any,
    );

    const requestData = { method: 'POST', body: { data: 'test' } };
    const expectedEncodedRequest = btoa(JSON.stringify(requestData));

    jest.spyOn(logger, 'error').mockImplementation(() => { });

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'error');

    httpLogger(
      logger,
      true,
      'process123',
      'doc123',
      requestData,
      { 'content-type': 'application/json' },
      'https://api.example.com',
    )({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => { },
      error: () => {
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 500,
            processId: 'process123',
            document: 'doc123',
            request: expectedEncodedRequest,
            headers: 'content-type:application/json',
            url: 'https://api.example.com',
          }),
        );
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should log with logger.verbose() on 3xx redirects', () => {
    jest.spyOn(logger, 'verbose').mockImplementation(() => { });

    const response = {
      status: 301,
      data: { location: '/new-url' },
    };

    const source$ = of(response);
    const logSpy = jest.spyOn(logger, 'verbose');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe();

    expect(logSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        code: 301,
        response: undefined,
      }),
    );
  });

  it('should log with logger.verbose() on 302 redirects', () => {
    jest.spyOn(logger, 'verbose').mockImplementation(() => { });

    const response = {
      status: 302,
      data: { location: '/another-url' },
    };

    const source$ = of(response);
    const logSpy = jest.spyOn(logger, 'verbose');

    httpLogger(
      logger,
      true,
      'proc1',
      'doc1',
      { test: 'data' },
      { 'x-custom': 'header' },
      'https://example.com',
    )({
      pipe: source$.pipe.bind(source$),
    }).subscribe();

    expect(logSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        code: 302,
        processId: 'proc1',
        document: 'doc1',
        url: 'https://example.com',
      }),
    );
  });
});

describe('internalLogger', () => {
  let logger: Logger;

  beforeEach(async () => {
    const moduleRef = await Test.createTestingModule({
      providers: [Logger],
    }).compile();

    logger = moduleRef.get<Logger>(Logger);
  });

  it('should log with logger.log() on successful internal operation', (done) => {
    jest.spyOn(logger, 'log').mockImplementation(() => { });
    const { internalLogger } = require('./httpLogger');
    const { of } = require('rxjs');

    const response = {
      result: { data: 'success', ruleId: '123' },
    };

    const source$ = of(response);
    const logSpy = jest.spyOn(logger, 'log');

    internalLogger(
      logger,
      true,
      'process-1',
      'doc-1',
      { input: 'test' },
      { 'x-header': 'value' },
      'ZEN_ENGINE',
    )(source$).subscribe({
      next: (result: any) => {
        expect(result).toEqual({ data: 'success', ruleId: '123' });
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 200,
            processId: 'process-1',
            document: 'doc-1',
            operation: 'ZEN_ENGINE',
          }),
        );
        done();
      },
      error: (err: any) => done(err),
    });
  });

  it('should throw NotFoundException when result is empty', (done) => {
    jest.spyOn(logger, 'warn').mockImplementation(() => { });
    const { internalLogger } = require('./httpLogger');
    const { of } = require('rxjs');

    const response = {
      result: {},
    };

    const source$ = of(response);

    const observer = {
      next: (val: any) => {
        done('Should not emit next');
      },
      error: (err: any) => {
        expect(err.status).toBe(404);
        expect(err.message).toContain('No se obtuvo resultado de la evaluación de reglas');
        done();
      },
    };
    internalLogger(logger)(source$).subscribe(observer);
  });

  it('should throw NotFoundException when result is null', (done) => {
    const { internalLogger } = require('./httpLogger');
    const { of } = require('rxjs');

    const response = {
      result: null,
    };

    const source$ = of(response);

    internalLogger(logger)(source$).subscribe({
      next: () => done(new Error('Should have thrown NotFoundException')),
      error: (err: any) => {
        expect(err.status).toBe(404);
        done();
      },
    });
  });

  it('should log with logger.warn() on 404 errors', (done) => {
    jest.spyOn(logger, 'warn').mockImplementation(() => { });
    const { internalLogger } = require('./httpLogger');
    const { throwError } = require('rxjs');
    const { NotFoundException } = require('@nestjs/common');

    const error = new NotFoundException('Resource not found');
    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'warn');

    internalLogger(
      logger,
      false,
      'proc-2',
      'doc-2',
      null,
      null,
      'SERVICE_BUS',
    )(source$).subscribe({
      next: () => done(new Error('Should have thrown error')),
      error: (err: any) => {
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 404,
            processId: 'proc-2',
            document: 'doc-2',
            operation: 'SERVICE_BUS',
          }),
        );
        done();
      },
    });
  });

  it('should log with logger.error() on 500 errors', (done) => {
    jest.spyOn(logger, 'error').mockImplementation(() => { });
    const { internalLogger } = require('./httpLogger');
    const { throwError } = require('rxjs');
    const { HttpException } = require('@nestjs/common');

    const error = new HttpException('Internal Server Error', 500);
    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'error');

    internalLogger(
      logger,
      true,
      'proc-3',
      'doc-3',
      { data: 'test' },
      { 'auth': 'token' },
      'OCR_SERVICE',
    )(source$).subscribe({
      next: () => done(new Error('Should have thrown error')),
      error: (err: any) => {
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 500,
            processId: 'proc-3',
            document: 'doc-3',
            operation: 'OCR_SERVICE',
          }),
        );
        done();
      },
    });
  });

  it('should log with logger.error() on generic errors', (done) => {
    jest.spyOn(logger, 'error').mockImplementation(() => { });
    const { internalLogger } = require('./httpLogger');
    const { throwError } = require('rxjs');

    const error = new Error('Generic error');
    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'error');

    internalLogger(logger)(source$).subscribe({
      next: () => done(new Error('Should have thrown error')),
      error: (err: any) => {
        expect(logSpy).toHaveBeenCalledWith(
          expect.objectContaining({
            code: 503,
            response: 'Generic error',
          }),
        );
        done();
      },
    });
  });
});
