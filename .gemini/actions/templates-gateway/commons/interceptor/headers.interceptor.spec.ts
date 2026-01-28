import { Test } from '@nestjs/testing';
import { ExecutionContext, CallHandler } from '@nestjs/common';
import { HeadersInterceptor } from './headers.interceptor';
import { of } from 'rxjs';
import { GqlExecutionContext } from '@nestjs/graphql';

describe('HeadersInterceptor', () => {
  let interceptor: HeadersInterceptor;
  let mockExecutionContext: ExecutionContext;
  let mockCallHandler: CallHandler;
  let mockGqlExecutionContext: GqlExecutionContext;

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
        getRequest: () => ({ headers: { 'test-header': 'test' } }),
      }),
    } as any;
    mockCallHandler = {
      handle: () => of('test'),
    };

    mockGqlExecutionContext = {
      getContext: () => ({
        req: {
          headers: { 'test-header': 'test' },
          path: '/test',
        },
      }),
    } as any;
  });

  it('should be defined', () => {
    expect(interceptor).toBeDefined();
  });

  it('should call handle() method if headers are present', () => {
    const spy = jest.spyOn(mockCallHandler, 'handle');
    interceptor.intercept(
      mockExecutionContext,
      mockCallHandler,
      mockGqlExecutionContext,
    );
    expect(spy).toHaveBeenCalled();
  });

  it('should throw an HttpException if headers are missing', () => {
    mockGqlExecutionContext = {
      getContext: () => ({
        req: {
          headers: {},
        },
      }),
    } as any;

    expect(() =>
      interceptor.intercept(
        mockExecutionContext,
        mockCallHandler,
        mockGqlExecutionContext,
      ),
    ).toThrow();
  });

  it('should throw an HttpException if a required header is missing', () => {
    mockGqlExecutionContext = {
      getContext: () => ({
        req: {
          headers: {},
          path: '/test',
        },
      }),
    } as any;

    expect(() =>
      interceptor.intercept(
        mockExecutionContext,
        mockCallHandler,
        mockGqlExecutionContext,
      ),
    ).toThrow();
  });
});
