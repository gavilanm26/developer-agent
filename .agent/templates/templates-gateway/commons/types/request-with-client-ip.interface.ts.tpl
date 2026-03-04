import { Request } from 'express';

export interface RequestWithClientIp extends Request {
  clientIp?: string;
}
