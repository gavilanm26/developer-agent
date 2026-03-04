import { extractClientIp } from './client-ip.util';
import { Request } from 'express';
import { Socket } from 'net';

describe('extractClientIp', () => {
  it('should return IP from x-forwarded-for header (multiple values)', () => {
    const req = {
      headers: {
        'x-forwarded-for': '123.45.67.89, 98.76.54.32',
      },
      socket: {} as Socket,
    } as unknown as Request;

    const ip = extractClientIp(req);
    expect(ip).toBe('123.45.67.89');
  });

  it('should return IP from x-forwarded-for header (single value)', () => {
    const req = {
      headers: {
        'x-forwarded-for': '200.100.50.25',
      },
      socket: {} as Socket,
    } as unknown as Request;

    const ip = extractClientIp(req);
    expect(ip).toBe('200.100.50.25');
  });

  it('should fallback to remoteAddress and strip ::ffff:', () => {
    const req = {
      headers: {},
      socket: {
        remoteAddress: '::ffff:192.168.0.1',
      } as unknown as Socket,
    } as Request;

    const ip = extractClientIp(req);
    expect(ip).toBe('192.168.0.1');
  });

  it('should return raw IPv4 from remoteAddress', () => {
    const req = {
      headers: {},
      socket: {
        remoteAddress: '172.16.5.10',
      } as unknown as Socket,
    } as Request;

    const ip = extractClientIp(req);
    expect(ip).toBe('172.16.5.10');
  });

  it('should return IPv6 address as fallback', () => {
    const req = {
      headers: {},
      socket: {
        remoteAddress: '::1',
      } as unknown as Socket,
    } as Request;

    const ip = extractClientIp(req);
    expect(ip).toBe('::1');
  });

  it('should handle IP with port and strip the port', () => {
    const req = {
      headers: {},
      socket: {
        remoteAddress: '186.28.0.77:57195',
      } as unknown as Socket,
    } as Request;

    const ip = extractClientIp(req);
    expect(ip).toBe('186.28.0.77');
  });

  it('should return "IP not available" if no source is available', () => {
    const req = {
      headers: {},
      socket: {
        remoteAddress: undefined,
      } as unknown as Socket,
    } as Request;

    const ip = extractClientIp(req);
    expect(ip).toBe('IP not available');
  });
});
