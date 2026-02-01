import { CryptoRequestGraphqlInterceptor } from './crypto.interceptor';
import { ExecutionContext, CallHandler } from '@nestjs/common';
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
    // Mock del contexto de GraphQL según el estándar de NestJS
    context = {
      getArgs: jest.fn().mockReturnValue([
        {}, // root
        {}, // args
        { // context
          info: { fieldName: 'test' },
          args: { data: 'encrypted_data' }
        }
      ]),
      getType: () => 'graphql'
    } as any;

    next = {
      handle: () => of('test'),
    };
    interceptor = new CryptoRequestGraphqlInterceptor();
  });

  it('should be defined', () => {
    expect(interceptor).toBeDefined();
  });

  it('should decrypt the data', (done) => {
    const decryptedData = JSON.stringify({ foo: 'bar' });

    // Mockear la respuesta del desencriptador
    jest.spyOn(Crypto, 'decrypt').mockReturnValue(decryptedData);

    // Actualizar el mock del contexto con datos "encriptados"
    const gqlCtx = {
      info: { fieldName: 'test' },
      args: { data: 'iv:tag:payload' }
    };
    (context.getArgs as jest.Mock).mockReturnValue([{}, {}, gqlCtx]);

    interceptor.intercept(context, next).subscribe(() => {
      // Verificar que se llamó a decrypt con el payload correcto
      expect(Crypto.decrypt).toHaveBeenCalledWith('iv:tag:payload');
      // Verificar que los datos en el contexto ahora son los desencriptados (objeto JSON)
      expect(gqlCtx.args.data).toEqual({ foo: 'bar' });
      done();
    });
  });
});