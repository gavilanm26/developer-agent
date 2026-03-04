import { ExecutionContext, HttpException } from '@nestjs/common';
import { HeadersInterceptor } from './headers.interceptor';

describe('HeadersInterceptor', () => {
  let interceptor: HeadersInterceptor;
  let mockContext: ExecutionContext;
  let mockNext: any;

  const requiredHeaders = ['id', 'header1', 'header2'];

  beforeEach(() => {
    interceptor = new HeadersInterceptor(requiredHeaders);
    mockContext = {
      switchToHttp: jest.fn(() => ({
        getRequest: jest.fn(() => ({
          headers: {
            id: 'value1',
            header1: 'value1',
            header2: 'value2',
          },
        })),
      })),
    } as any;
    mockNext = {
      handle: jest.fn(),
    };
  });

  it('should pass through when all required headers are present', () => {
    interceptor.intercept(mockContext, mockNext);
    expect(mockNext.handle).toHaveBeenCalled();
  });

  it('should throw HttpException with status 400 when a required header is missing', () => {
    const mockMissingHeaderContext: any = {
      ...mockContext,
      switchToHttp: jest.fn(() => ({
        getRequest: jest.fn(() => ({
          headers: {
            header3: 'value3',
          },
        })),
      })),
    };

    expect(() => {
      interceptor.intercept(mockMissingHeaderContext, mockNext);
    }).toThrow(HttpException);
  });
});
