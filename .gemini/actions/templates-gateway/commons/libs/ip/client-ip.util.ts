import { Request } from 'express';

export function extractClientIp(req: Request): string {
  const forwarded = req.headers['x-forwarded-for'];
  let ip = '';

  if (typeof forwarded === 'string' && forwarded.length > 0) {
    ip = forwarded.split(',')[0].trim();
    if (ip.includes(':')) {
      ip = ip.split(':')[0];
    }
    return ip;
  }

  ip = req.socket?.remoteAddress ?? 'IP not available';

  if (ip.startsWith('::ffff:')) {
    ip = ip.replace('::ffff:', '');
  }

  if (ip.includes(':')) {
    const parts = ip.split(':');
    const ipv4 = parts.find((part) => /^\d{1,3}(\.\d{1,3}){3}$/.test(part));
    if (ipv4) ip = ipv4;
  }

  return ip;
}
