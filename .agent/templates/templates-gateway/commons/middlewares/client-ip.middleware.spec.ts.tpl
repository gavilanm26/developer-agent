import { clientIpMiddleware } from './client-ip.middleware';
import { extractClientIp } from '../libs/ip/client-ip.util';
import { Request, Response, NextFunction } from 'express';

jest.mock('../libs/ip/client-ip.util', () => ({
  extractClientIp: jest.fn(),
}));

describe('clientIpMiddleware', () => {
  let req: Partial<Request> & { clientIp?: string };
  let res: Partial<Response>;
  let next: NextFunction;

  beforeEach(() => {
    req = {
      headers: {},
    };
    res = {};
    next = jest.fn();
  });

  it('You must assign the IP returned by extractclientip to req.clientip', () => {
    const fakeIp = '190.85.20.100';
    (extractClientIp as jest.Mock).mockReturnValue(fakeIp);

    clientIpMiddleware(req as Request, res as Response, next);

    expect(req.clientIp).toBe(fakeIp);
    expect(extractClientIp).toHaveBeenCalledWith(req);
    expect(next).toHaveBeenCalled();
  });

  it('You must continue without errors although extractclientip return Undefined', () => {
    (extractClientIp as jest.Mock).mockReturnValue(undefined);

    clientIpMiddleware(req as Request, res as Response, next);

    expect(req.clientIp).toBeUndefined();
    expect(next).toHaveBeenCalled();
  });
});
