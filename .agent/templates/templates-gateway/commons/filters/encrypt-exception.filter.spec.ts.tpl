import { HttpException, HttpStatus } from '@nestjs/common';
import { EncryptExceptionFilter } from './encrypt-exception.filter';
import Crypto from '../crypto/crypto';

jest.mock('../crypto/crypto', () => ({
  __esModule: true,
  default: { encrypt: jest.fn() },
}));

describe('EncryptExceptionFilter', () => {
  const HSTS_KEY = 'Strict-Transport-Security';
  const HSTS_VAL = 'max-age=31536000; includeSubDomains; preload';
  let filter: EncryptExceptionFilter;
  let res: any;
  let host: any;

  beforeAll(() => {
    process.env.APPENCRYPTKEYTWO = 'test-k2';
  });

  beforeEach(() => {
    jest.clearAllMocks();
    filter = new EncryptExceptionFilter();
    res = {
      setHeader: jest.fn(),
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };
    host = {
      switchToHttp: () => ({
        getResponse: () => res,
      }),
    };
    (Crypto.encrypt as jest.Mock).mockReturnValue('ENCRYPTED');
  });

  it('maps NOT_FOUND (404) from HttpException to NO_CONTENT (204) and encrypts object body', () => {
    const exception = new HttpException({ foo: 'bar' }, HttpStatus.NOT_FOUND);
    filter.catch(exception as any, host);
    expect(res.setHeader).toHaveBeenCalledWith(HSTS_KEY, HSTS_VAL);
    expect(res.status).toHaveBeenCalledWith(HttpStatus.NO_CONTENT);
    expect(Crypto.encrypt).toHaveBeenCalledWith(
      JSON.stringify({ foo: 'bar' }),
      'test-k2',
    );
    expect(res.json).toHaveBeenCalledWith({ response: 'ENCRYPTED' });
  });

  it('keeps PARTIAL_CONTENT (206) from HttpException and encrypts object body', () => {
    const exception = new HttpException(
      { ok: true },
      HttpStatus.PARTIAL_CONTENT,
    );
    filter.catch(exception as any, host);
    expect(res.setHeader).toHaveBeenCalledWith(HSTS_KEY, HSTS_VAL);
    expect(res.status).toHaveBeenCalledWith(HttpStatus.PARTIAL_CONTENT);
    expect(Crypto.encrypt).toHaveBeenCalledWith(
      JSON.stringify({ ok: true }),
      'test-k2',
    );
    expect(res.json).toHaveBeenCalledWith({ response: 'ENCRYPTED' });
  });

  it('keeps NO_CONTENT (204) from HttpException', () => {
    const exception = new HttpException({ a: 1 }, HttpStatus.NO_CONTENT);
    filter.catch(exception as any, host);
    expect(res.status).toHaveBeenCalledWith(HttpStatus.NO_CONTENT);
  });

  it('maps UNAUTHORIZED (401) from generic error response and encrypts object body', () => {
    const exception = {
      response: { status: HttpStatus.UNAUTHORIZED, data: { reason: 'x' } },
    };
    filter.catch(exception as any, host);
    expect(res.setHeader).toHaveBeenCalledWith(HSTS_KEY, HSTS_VAL);
    expect(res.status).toHaveBeenCalledWith(HttpStatus.UNAUTHORIZED);
    expect(Crypto.encrypt).toHaveBeenCalledWith(
      JSON.stringify({ reason: 'x' }),
      'test-k2',
    );
    expect(res.json).toHaveBeenCalledWith({ response: 'ENCRYPTED' });
  });

  it('maps NOT_FOUND (404) from generic error to NO_CONTENT (204) and wraps string data into {message}', () => {
    const exception = {
      response: { status: HttpStatus.NOT_FOUND, data: 'missing' },
    };
    filter.catch(exception as any, host);
    expect(res.setHeader).toHaveBeenCalledWith(HSTS_KEY, HSTS_VAL);
    expect(res.status).toHaveBeenCalledWith(HttpStatus.NO_CONTENT);
    expect(Crypto.encrypt).toHaveBeenCalledWith(
      JSON.stringify({ message: 'missing' }),
      'test-k2',
    );
    expect(res.json).toHaveBeenCalledWith({ response: 'ENCRYPTED' });
  });

  it('defaults to 500 when no status and uses default message', () => {
    const exception = {};
    filter.catch(exception as any, host);
    expect(res.setHeader).toHaveBeenCalledWith(HSTS_KEY, HSTS_VAL);
    expect(res.status).toHaveBeenCalledWith(HttpStatus.INTERNAL_SERVER_ERROR);
    expect(Crypto.encrypt).toHaveBeenCalledWith(
      JSON.stringify({ message: 'Internal Server Error' }),
      'test-k2',
    );
    expect(res.json).toHaveBeenCalledWith({ response: 'ENCRYPTED' });
  });

  it('passes through unknown status codes not in map', () => {
    const exception = { response: { status: 418, data: { t: true } } };
    filter.catch(exception as any, host);
    expect(res.status).toHaveBeenCalledWith(418);
    expect(Crypto.encrypt).toHaveBeenCalledWith(
      JSON.stringify({ t: true }),
      'test-k2',
    );
  });

  it('wraps string body from HttpException into {message}', () => {
    const exception = new HttpException('oops', HttpStatus.BAD_REQUEST);
    filter.catch(exception as any, host);
    expect(res.status).toHaveBeenCalledWith(HttpStatus.BAD_REQUEST);
    expect(Crypto.encrypt).toHaveBeenCalledWith(
      JSON.stringify({ message: 'oops' }),
      'test-k2',
    );
  });
});
