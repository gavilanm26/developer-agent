import { StatusCodeInterceptor } from './status-code.interceptor';
import { CallHandler, ExecutionContext } from '@nestjs/common';
import { of } from 'rxjs';

describe('StatusCodeInterceptor', () => {
  let interceptor: StatusCodeInterceptor;
  let responseMock: any;
  let callHandler: Partial<CallHandler>;
  let context: ExecutionContext;

  beforeEach(() => {
    interceptor = new StatusCodeInterceptor();

    responseMock = {
      status: jest.fn().mockReturnThis(),
    };

    callHandler = {
      handle: () => of({ statusCode: 206, data: 'test-data' }),
    };

    context = {
      switchToHttp: () => ({
        getRequest: () => ({}),
        getResponse: () => responseMock,
        getNext: () => undefined,
      }),
    } as Partial<ExecutionContext> as ExecutionContext;
  });

  it('must establish the status http when statuscode is present', (done) => {
    interceptor
      .intercept(context, callHandler as CallHandler)
      .subscribe((result) => {
        expect(responseMock.status).toHaveBeenCalledWith(206);
        expect(result).toEqual({ data: 'test-data' });
        done();
      });
  });

  it('You should do nothing if statuscode is not present', (done) => {
    callHandler.handle = () => of({ data: 'ok' });

    interceptor
      .intercept(context, callHandler as CallHandler)
      .subscribe((result) => {
        expect(responseMock.status).not.toHaveBeenCalled();
        expect(result).toEqual({ data: 'ok' });
        done();
      });
  });
});
