import { Test } from '@nestjs/testing';
import { ExecutionContext, CallHandler } from '@nestjs/common';
import { HeadersInterceptor } from './headers.interceptor';
import { of } from 'rxjs';
// <<GQL
import { GqlExecutionContext } from '@nestjs/graphql';
// GQL>>

describe('HeadersInterceptor', () => {
  let interceptor: HeadersInterceptor;
  let mockExecutionContext: ExecutionContext;
  let mockCallHandler: CallHandler;
  // <<GQL
  let mockGqlExecutionContext: GqlExecutionContext;
  // GQL>>

  beforeEach(async () => {
    interceptor = new HeadersInterceptor(['test-header']);
    
    mockExecutionContext = {
      getType: () => 'http',
      switchToHttp: () => ({
        getRequest: () => ({ 
          headers: { 'test-header': 'test' },
          path: '/test'
        }),
      }),
      getArgs: () => [{}, {}, { req: { headers: { 'test-header': 'test' }, path: '/test' } }]
    } as any;

    mockCallHandler = {
      handle: () => of('test'),
    };
  });

  it('should be defined', () => {
    expect(interceptor).toBeDefined();
  });

  it('should call handle() method if headers are present in HTTP', () => {
    const spy = jest.spyOn(mockCallHandler, 'handle');
    interceptor.intercept(mockExecutionContext, mockCallHandler);
    expect(spy).toHaveBeenCalled();
  });

  // <<GQL
  it('should call handle() method if headers are present in GQL', () => {
    (mockExecutionContext.getType as jest.Mock) = jest.fn().mockReturnValue('graphql');
    const spy = jest.spyOn(mockCallHandler, 'handle');
    interceptor.intercept(mockExecutionContext, mockCallHandler);
    expect(spy).toHaveBeenCalled();
  });
  // GQL>>

  it('should throw an HttpException if a required header is missing', () => {
    (mockExecutionContext.switchToHttp as jest.Mock) = jest.fn().mockReturnValue({
      getRequest: () => ({ headers: {}, path: '/test' })
    });

    expect(() =>
      interceptor.intercept(mockExecutionContext, mockCallHandler),
    ).toThrow();
  });
});
