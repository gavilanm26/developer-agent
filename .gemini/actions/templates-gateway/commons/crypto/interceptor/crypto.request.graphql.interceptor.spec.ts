import { CryptoRequestGraphqlInterceptor } from './crypto.interceptor';
import { ExecutionContext, CallHandler } from '@nestjs/common';
import { GqlExecutionContext } from '@nestjs/graphql';
import { of } from 'rxjs';
import Crypto from '../crypto';

const originalEnvEncryptKey = process.env.APPENCRYPTKEY;
process.env.APPENCRYPTKEY = 'mocked-encrypt-key';
describe('CryptoRequestGraphqlInterceptor', () => {
  let interceptor: CryptoRequestGraphqlInterceptor;
  let context: ExecutionContext;
  let next: CallHandler;

  afterAll(() => {
    process.env.APPENCRYPTKEY = originalEnvEncryptKey;
  });

  beforeEach(() => {
    jest.spyOn(GqlExecutionContext, 'create').mockImplementation(
      () =>
        ({
          getInfo: () => ({ fieldName: 'test' }),
          getArgs: () => ({ data: 'encrypted_data' }),
        }) as any,
    );

    context = {} as any;
    next = {
      handle: () => of('test'),
    };
    interceptor = new CryptoRequestGraphqlInterceptor();
  });

  it('should be defined', () => {
    expect(interceptor).toBeDefined();
  });

  it('should decrypt the data', () => {
    const decryptedData = { foo: 'bar' };

    // Crear una cadena encriptada simulada que sea válida
    const iv = '123456789012345678901234';
    const authTag = 'abcdefabcdefabcdefabcdef';
    const encryptedData = `${iv}:${authTag}:encrypted_data`;

    jest
      .spyOn(Crypto, 'decrypt' as never)
      .mockReturnValue(decryptedData as never);

    jest.spyOn(GqlExecutionContext, 'create').mockImplementation(
      () =>
        ({
          getInfo: () => ({ fieldName: 'test' }),
          getArgs: () => ({ data: encryptedData }),
        }) as any,
    );

    interceptor.intercept(context, next);

    expect(GqlExecutionContext.create(context).getArgs().data).toEqual(
      '123456789012345678901234:abcdefabcdefabcdefabcdef:encrypted_data',
    );
  });
});
