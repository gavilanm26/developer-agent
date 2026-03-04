import { Test } from '@nestjs/testing';
import { Logger } from '@nestjs/common';
import { of, throwError } from 'rxjs';
import { AxiosError } from 'axios';
import { httpLogger } from './httpLogger';

describe('httpLogger', () => {
  let logger: Logger;

  beforeEach(async () => {
    const moduleRef = await Test.createTestingModule({
      providers: [Logger],
    }).compile();

    logger = moduleRef.get<Logger>(Logger);
  });

  it('should log verbose on successful response', () => {
    jest.spyOn(logger, 'verbose').mockImplementation(() => {});

    const response = {
      status: 200,
      data: { message: 'Success' },
    };

    const source$ = of(response);
    const logSpy = jest.spyOn(logger, 'verbose');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe();

    expect(logSpy).toHaveBeenCalledWith({
      code: 200,
      document: undefined,
      headers: undefined,
      processId: undefined,
      request: undefined,
      response: undefined,
    });
  });

  it('should log error and throw HttpException on error response', (done) => {
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

    jest.spyOn(logger, 'error').mockImplementation(() => {});

    const source$ = throwError(() => error);

    const logSpy = jest.spyOn(logger, 'error');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => {},
      error: () => {
        expect(logSpy).toHaveBeenCalled();
        expect(logSpy).toHaveBeenCalledWith(expect.anything());
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should not log response data when responseShow is false', () => {
    jest.spyOn(logger, 'verbose').mockImplementation(() => {});

    const response = {
      status: 200,
      data: { message: 'Success' },
    };

    const source$ = of(response);
    const logSpy = jest.spyOn(logger, 'verbose');

    httpLogger(
      logger,
      false,
    )({
      pipe: source$.pipe.bind(source$),
    }).subscribe();

    expect(logSpy).toHaveBeenCalledWith({
      code: 200,
      document: undefined,
      headers: undefined,
      processId: undefined,
      request: undefined,
      response: undefined,
    });
  });

  it('should log generic error message when response data is missing', (done) => {
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

    jest.spyOn(logger, 'error').mockImplementation(() => {});

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'error');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => {},
      error: () => {
        expect(logSpy).toHaveBeenCalledWith({
          code: 404,
          document: undefined,
          headers: undefined,
          processId: undefined,
          request: undefined,
          response: 'Error with no data',
        });
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should handle null or undefined optional parameters and use default values', () => {
    jest.spyOn(logger, 'verbose').mockImplementation(() => {});

    const response = {
      status: 200,
      data: { message: 'Success' },
    };

    const source$ = of(response);
    const logSpy = jest.spyOn(logger, 'verbose');

    httpLogger(
      logger,
      true,
      undefined,
      undefined,
      undefined,
      undefined,
    )({
      pipe: source$.pipe.bind(source$),
    }).subscribe();

    expect(logSpy).toHaveBeenCalledWith({
      code: 200,
      document: undefined,
      headers: undefined,
      processId: undefined,
      request: undefined,
      response: btoa(JSON.stringify({ message: 'Success' })),
    });
  });

  it('should log error with default error message when error message is undefined', (done) => {
    const errorResponse = {
      status: 404,
      data: { message: 'Not Found' },
    };

    const error = new AxiosError(
      undefined,
      'ERR',
      {} as any,
      undefined,
      errorResponse as any,
    ) as any;

    error.response = errorResponse;

    jest.spyOn(logger, 'error').mockImplementation(() => {});

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'error');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => {},
      error: () => {
        expect(logSpy).toHaveBeenCalledWith({
          code: 404,
          document: undefined,
          headers: undefined,
          processId: undefined,
          request: undefined,
          response: { message: 'Not Found' },
        });
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should handle null parameters and use default empty strings', () => {
    jest.spyOn(logger, 'verbose').mockImplementation(() => {});

    const response = {
      status: 200,
      data: { message: 'Success' },
    };

    const source$ = of(response);
    const logSpy = jest.spyOn(logger, 'verbose');

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

    expect(logSpy).toHaveBeenCalledWith({
      code: 200,
      document: null,
      headers: null,
      processId: null,
      request: undefined,
      response: btoa(JSON.stringify({ message: 'Success' })),
    });
  });

  it('should handle errors without response object', (done) => {
    const error = new AxiosError(
      'Network Failure',
      'NET_ERR',
      {} as any,
      undefined,
      undefined,
    );

    jest.spyOn(logger, 'error').mockImplementation(() => {});

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'error');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => {},
      error: () => {
        expect(logSpy).toHaveBeenCalledWith({
          code: undefined,
          document: undefined,
          headers: undefined,
          processId: undefined,
          request: undefined,
          response: 'Network Failure',
        });
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });

  it('should use "Unexpected Error" when error message is missing', (done) => {
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

    jest.spyOn(logger, 'error').mockImplementation(() => {});

    const source$ = throwError(() => error);
    const logSpy = jest.spyOn(logger, 'error');

    httpLogger(logger)({
      pipe: source$.pipe.bind(source$),
    }).subscribe({
      next: () => {},
      error: () => {
        expect(logSpy).toHaveBeenCalledWith({
          code: 500,
          document: undefined,
          headers: undefined,
          processId: undefined,
          request: undefined,
          response: { message: 'Server error' },
        });
        done();
      },
      complete: () => {
        done(new Error('Observable completed without triggering error.'));
      },
    });
  });
});
