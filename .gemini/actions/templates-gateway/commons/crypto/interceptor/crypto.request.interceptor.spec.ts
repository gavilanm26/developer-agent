import { ExecutionContext, CallHandler } from '@nestjs/common';
import { CryptoRequestInterceptor } from './crypto.interceptor';
import Crypto from '../crypto';

describe('CryptoRequestInterceptor', () => {
  let interceptor: CryptoRequestInterceptor;
  let mockContext: ExecutionContext;
  let mockNext: CallHandler<any>;

  beforeEach(() => {
    interceptor = new CryptoRequestInterceptor();
    mockContext = {
      switchToHttp: jest.fn().mockImplementation(() => ({
        getRequest: jest.fn().mockReturnValue({
          body: { data: 'encrypted-data' },
        }),
      })),
      getType: jest.fn().mockReturnValue('http'),
    } as unknown as ExecutionContext;

    mockNext = {
      handle: jest.fn().mockReturnValue({}),
    } as CallHandler<any>;
  });

  it('should decrypt and parse the data in the request body', () => {
    const decryptSpy = jest
      .spyOn(Crypto, 'decrypt')
      .mockReturnValue('{"message": "decrypted-data"}');
    const jsonParseSpy = jest.spyOn(JSON, 'parse');

    interceptor.intercept(mockContext, mockNext);

    expect(decryptSpy).toHaveBeenCalledWith('encrypted-data');
    expect(jsonParseSpy).toHaveBeenCalledWith('{"message": "decrypted-data"}');
    expect(mockNext.handle).toHaveBeenCalled();
  });

  it('should set the decrypted data in the request body when parsing fails', () => {
    const decryptSpy = jest
      .spyOn(Crypto, 'decrypt')
      .mockReturnValue('invalid-json');

    interceptor.intercept(mockContext, mockNext);

    expect(decryptSpy).toHaveBeenCalledWith('encrypted-data');
    expect(mockNext.handle).toHaveBeenCalled();
  });
});
