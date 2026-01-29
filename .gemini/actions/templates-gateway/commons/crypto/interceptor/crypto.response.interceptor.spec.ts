import { CallHandler } from '@nestjs/common';
import { of } from 'rxjs';
import { CryptoResponseInterceptor } from './crypto.interceptor';
import Crypto from '../crypto';
import { ExecutionContextHost } from '@nestjs/core/helpers/execution-context-host';

describe('CryptoResponseInterceptor', () => {
  let interceptor: CryptoResponseInterceptor;
  let mockNext: CallHandler<any>;

  beforeEach(() => {
    interceptor = new CryptoResponseInterceptor();
    mockNext = {
      handle: jest.fn().mockReturnValue(of({ message: 'data' })),
    } as CallHandler<any>;
  });

  it('should encrypt the response data', (done) => {
    const mockRequest = { url: '/test' };
    const mockExecutionContext = new ExecutionContextHost([mockRequest]);

    const switchToHttpSpy = jest
      .spyOn(mockExecutionContext, 'switchToHttp')
      .mockReturnValue({
        getRequest: jest.fn().mockReturnValue(mockRequest),
      } as any);

    const encryptSpy = jest
      .spyOn(Crypto, 'encrypt')
      .mockReturnValue('encrypted-data');

    interceptor
      .intercept(mockExecutionContext, mockNext)
      .subscribe((result) => {
        expect(switchToHttpSpy).toHaveBeenCalled();
        expect(mockRequest.url).toBe('/test');
        expect(encryptSpy).toHaveBeenCalledWith({ message: 'data' });
        expect(result).toEqual({ response: 'encrypted-data' });
        done();
      });
  });

  it('should not encrypt the response data when request.url is "/health"', (done) => {
    const mockRequest = { url: '/health' };
    const mockExecutionContext = new ExecutionContextHost([mockRequest]);

    const switchToHttpSpy = jest
      .spyOn(mockExecutionContext, 'switchToHttp')
      .mockReturnValue({
        getRequest: jest.fn().mockReturnValue(mockRequest),
      } as any);

    interceptor
      .intercept(mockExecutionContext, mockNext)
      .subscribe((result) => {
        expect(switchToHttpSpy).toHaveBeenCalled();
        expect(mockRequest.url).toBe('/health');
        expect(result).toEqual({ message: 'data' });
        done();
      });
  });

  it('should return data when request.url is not "/health" but data is undefined', (done) => {
    const mockRequest = { url: '/other' };
    const mockExecutionContext = new ExecutionContextHost([mockRequest]);

    const switchToHttpSpy = jest
      .spyOn(mockExecutionContext, 'switchToHttp')
      .mockReturnValue({
        getRequest: jest.fn().mockReturnValue(mockRequest),
      } as any);

    const mockNextWithDataUndefined = {
      handle: jest.fn().mockReturnValue(of(undefined)),
    } as CallHandler<any>;

    interceptor
      .intercept(mockExecutionContext, mockNextWithDataUndefined)
      .subscribe((result) => {
        expect(switchToHttpSpy).toHaveBeenCalled();
        expect(mockRequest.url).toBe('/other');
        expect(result).toBeUndefined();
        done();
      });
  });


});
