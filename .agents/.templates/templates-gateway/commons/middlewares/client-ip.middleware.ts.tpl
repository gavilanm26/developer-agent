import { Request, Response, NextFunction } from 'express';
import { extractClientIp } from '../libs/ip';

export function clientIpMiddleware(
  req: Request & { clientIp?: string },
  res: Response,
  next: NextFunction,
): void {
  const ip = extractClientIp(req);
  req.clientIp = ip;
  next();
}
