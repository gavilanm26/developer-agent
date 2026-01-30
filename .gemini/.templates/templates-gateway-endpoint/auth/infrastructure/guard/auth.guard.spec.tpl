import { UnauthorizedException, Logger } from '@nestjs/common';

import { of, throwError } from 'rxjs';
import { HttpService } from '@nestjs/axios';
import type { AxiosResponse } from 'axios';

import { JwtAuthGuard } from './auth.guard';

jest.mock('jsonwebtoken', () => ({
  verify: jest.fn(),
  decode: jest.fn(),
}));
jest.mock('../../domain/jwt.config', () => ({
  __esModule: true,
  default: { publicKey: 'test-public-key', algorithm: 'HS256' },
}));
jest.mock('../../../../commons/crypto/crypto', () => ({
  __esModule: true,
  default: { decrypt: jest.fn() },
}));

import * as jwt from 'jsonwebtoken';
import Crypto from '../../../../commons/crypto/crypto';

describe('JwtAuthGuard', () => {
  let guard: JwtAuthGuard;
  let httpService: jest.Mocked<HttpService>;
  let warnSpy: jest.SpyInstance;
  let errorSpy: jest.SpyInstance;
  const originalEnv = process.env;

  const makeAxiosResponse = <T = unknown>(
    status: number,
    data?: T,
  ): AxiosResponse<T> => ({
    data: data as T,
    status,
    statusText: String(status),
    headers: {},
    config: {} as any,
  });

  const mockExecutionContext = (req: any): any => ({
    switchToHttp: () => ({
      getRequest: () => req,
    }),
  });

  beforeAll(() => {
    process.env = { ...originalEnv };
    process.env.APIURLIDENTITYMANAGEMENT = 'http://identity';
    process.env.APPENCRYPTJWT = 'app-secret';
  });

  beforeEach(() => {
    jest.clearAllMocks();
    httpService = { get: jest.fn() } as unknown as jest.Mocked<HttpService>;
    guard = new JwtAuthGuard(httpService);

    warnSpy = jest
      .spyOn(Logger.prototype, 'warn')
      .mockImplementation(() => undefined);
    errorSpy = jest
      .spyOn(Logger.prototype, 'error')
      .mockImplementation(() => undefined);
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  const bearer = (t: string) => `Bearer ${t}`;

  it('Lanza Unauthorized when there is no authorization', async () => {
    const req = { headers: {} };
    const ctx = mockExecutionContext(req);
    await expect(guard.canActivate(ctx)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });

  it('Lanza Unauthorized when jwt.verify failure', async () => {
    (jwt.verify as jest.Mock).mockImplementation(() => {
      throw new Error('bad token');
    });
    const req = { headers: { authorization: bearer('tok') } };
    const ctx = mockExecutionContext(req);

    await expect(guard.canActivate(ctx)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
    expect(errorSpy).toHaveBeenCalledWith(
      'Error al verificar el token JWT',
      expect.any(String),
    );
  });

  it('The request returns if there is no body.data (valid token)', async () => {
    (jwt.verify as jest.Mock).mockImplementation(() => undefined);
    const req = { headers: { authorization: bearer('tok') } };
    const ctx = mockExecutionContext(req);

    const result = await guard.canActivate(ctx);
    expect(result).toBe(req as any);
  });

  it('Lanza Unauthorized when jwt.decode does not bring data in the payload', async () => {
    (jwt.verify as jest.Mock).mockImplementation(() => undefined);
    (jwt.decode as jest.Mock).mockReturnValue({ foo: 'bar' });
    const req = {
      headers: { authorization: bearer('tok') },
      body: { data: 'cipher' },
    };
    const ctx = mockExecutionContext(req);

    await expect(guard.canActivate(ctx)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
    expect(warnSpy).toHaveBeenCalledWith('No se pudo desencriptar el token');
  });

  it('Lanza Unauthorized when Token Decrypt launches error', async () => {
    (jwt.verify as jest.Mock).mockImplementation(() => undefined);
    (jwt.decode as jest.Mock).mockReturnValue({ data: 'token-encrypted' });
    (Crypto.decrypt as jest.Mock).mockImplementation(() => {
      throw new Error('decrypt fail');
    });

    const req = {
      headers: { authorization: bearer('tok') },
      body: { data: 'cipher' },
    };
    const ctx = mockExecutionContext(req);

    await expect(guard.canActivate(ctx)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
    expect(errorSpy).toHaveBeenCalledWith(
      'Error al desencriptar o decodificar el token',
      expect.any(String),
    );
  });

  it('Lanza Unauthorized when the document number does not match (body.DocumentNumber)', async () => {
    (jwt.verify as jest.Mock).mockImplementation(() => undefined);
    (jwt.decode as jest.Mock).mockReturnValue({ data: 'token-encrypted' });

    (Crypto.decrypt as jest.Mock)
      .mockReturnValueOnce(
        JSON.stringify({ documentNumber: '123', processId: 'p-1' }),
      )
      .mockReturnValueOnce(JSON.stringify({ documentNumber: '999' }));

    const req = {
      headers: { authorization: bearer('tok') },
      body: { data: 'body-encrypted' },
    };
    const ctx = mockExecutionContext(req);

    await expect(guard.canActivate(ctx)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
    expect(warnSpy).toHaveBeenCalledWith(
      'Los documentos no coinciden. Body: 999, Token: 123',
    );
  });

  it('Accept when body.userdata.documentNumber coincides and validatetokenwithService returns 200', async () => {
    (jwt.verify as jest.Mock).mockImplementation(() => undefined);
    (jwt.decode as jest.Mock).mockReturnValue({ data: 'token-encrypted' });

    (Crypto.decrypt as jest.Mock)
      .mockReturnValueOnce(
        JSON.stringify({ documentNumber: 'ABC', processId: 'proc-123' }),
      )
      .mockReturnValueOnce({ userData: { documentNumber: 'ABC' } });

    httpService.get.mockReturnValue(of(makeAxiosResponse(200)));

    const req = {
      headers: { authorization: bearer('tok') },
      body: { data: 'body-encrypted' },
    };
    const ctx = mockExecutionContext(req);

    const result = await guard.canActivate(ctx);
    expect(result).toBe(req as any);
    expect(httpService.get).toHaveBeenCalledWith(
      'http://identity/v1/redis/proc-123',
    );
  });

  it('Accept when processid is the object {consecutive} and service returns 200', async () => {
    (jwt.verify as jest.Mock).mockImplementation(() => undefined);
    (jwt.decode as jest.Mock).mockReturnValue({ data: 'token-encrypted' });

    (Crypto.decrypt as jest.Mock)
      .mockReturnValueOnce(
        JSON.stringify({
          documentNumber: '777',
          processId: { consecutive: 'XYZ-9' },
        }),
      )
      .mockReturnValueOnce(JSON.stringify({ documentNumber: '777' }));

    httpService.get.mockReturnValue(of(makeAxiosResponse(200)));

    const req = {
      headers: { authorization: bearer('tok') },
      body: { data: 'body-encrypted' },
    };
    const ctx = mockExecutionContext(req);

    const result = await guard.canActivate(ctx);
    expect(result).toBe(req as any);
    expect(httpService.get).toHaveBeenCalledWith(
      'http://identity/v1/redis/XYZ-9',
    );
  });

  it('Lanza Unauthorized when service returns status! = 200', async () => {
    (jwt.verify as jest.Mock).mockImplementation(() => undefined);
    (jwt.decode as jest.Mock).mockReturnValue({ data: 'token-encrypted' });

    (Crypto.decrypt as jest.Mock)
      .mockReturnValueOnce(
        JSON.stringify({ documentNumber: '1', processId: 'p-2' }),
      )
      .mockReturnValueOnce(JSON.stringify({ documentNumber: '1' }));

    httpService.get.mockReturnValue(of(makeAxiosResponse(404)));

    const req = {
      headers: { authorization: bearer('tok') },
      body: { data: 'body-encrypted' },
    };
    const ctx = mockExecutionContext(req);

    await expect(guard.canActivate(ctx)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
    expect(warnSpy).toHaveBeenCalledWith('Validación fallida.');
  });

  it('Lanza Unauthorized when the service launches error (Catch -> false)', async () => {
    (jwt.verify as jest.Mock).mockImplementation(() => undefined);
    (jwt.decode as jest.Mock).mockReturnValue({ data: 'token-encrypted' });

    (Crypto.decrypt as jest.Mock)
      .mockReturnValueOnce(
        JSON.stringify({ documentNumber: '55', processId: 'boom' }),
      )
      .mockReturnValueOnce(JSON.stringify({ documentNumber: '55' }));

    httpService.get.mockReturnValue(
      throwError(() => new Error('network')) as any,
    );

    const req = {
      headers: { authorization: bearer('tok') },
      body: { data: 'body-encrypted' },
    };
    const ctx = mockExecutionContext(req);

    await expect(guard.canActivate(ctx)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
    expect(warnSpy).toHaveBeenCalledWith('Validación fallida.');
  });

  it("Lanza Unauthorized when you can't get bodily stop.", async () => {
    (jwt.verify as jest.Mock).mockImplementation(() => undefined);
    (jwt.decode as jest.Mock).mockReturnValue({ data: 'token-encrypted' });

    (Crypto.decrypt as jest.Mock)
      .mockReturnValueOnce(
        JSON.stringify({ documentNumber: '123', processId: 'p-3' }),
      )
      .mockImplementationOnce(() => {
        throw new Error('bad body');
      });

    const req = {
      headers: { authorization: bearer('tok') },
      body: { data: 'body-encrypted' },
    };
    const ctx = mockExecutionContext(req);

    await expect(guard.canActivate(ctx)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
    expect(errorSpy).toHaveBeenCalledWith(
      'Error al desencriptar o parsear body.data',
      expect.any(String),
    );
  });
});
