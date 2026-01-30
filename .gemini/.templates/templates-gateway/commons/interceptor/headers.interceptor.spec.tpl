import { Test } from '@nestjs/testing';
import { ExecutionContext, CallHandler } from '@nestjs/common';
import { HeadersInterceptor } from './headers.interceptor';
import { of } from 'rxjs';


describe('HeadersInterceptor', () => {
  let interceptor: HeadersInterceptor;
  let mockExecutionContext: ExecutionContext;
  let mockCallHandler: CallHandler;

  beforeEach(async () => {
    const moduleRef = await Test.createTestingModule({
      providers: [
        {
          provide: HeadersInterceptor,
          useValue: new HeadersInterceptor(['test-header']),
        },
      ],
    }).compile();

    interceptor = moduleRef.get<HeadersInterceptor>(HeadersInterceptor);
    mockExecutionContext = {
      switchToHttp: () => ({
        getRequest: () => ({
          headers: { 'test-header': 'test' },
          path: '/test',
        }),
      }),
    } as any;
    mockCallHandler = {
      handle: () => of('test'),
    };
  });

  it('should be defined', () => {
    expect(interceptor).toBeDefined();
  });

  it('should call handle() method if headers are present', () => {
    const spy = jest.spyOn(mockCallHandler, 'handle');
    interceptor.intercept(mockExecutionContext, mockCallHandler);
    expect(spy).toHaveBeenCalled();
  });

  it('should throw an HttpException if headers are missing', () => {
    mockExecutionContext = {
      switchToHttp: () => ({
        getRequest: () => ({ headers: {}, path: '/test' }),
      }),
    } as any;

    expect(() =>
      interceptor.intercept(mockExecutionContext, mockCallHandler),
    ).toThrow();
  });

  it('should throw an HttpException if a required header is missing', () => {
    mockExecutionContext = {
      switchToHttp: () => ({
        getRequest: () => ({ headers: {}, path: '/test' }),
      }),
    } as any;

    expect(() =>
      interceptor.intercept(mockExecutionContext, mockCallHandler),
    ).toThrow();
  });
});
