import { Injectable } from '@nestjs/common';
import { AuthRequest } from '@modules/auth/domain/models/auth-request.model';
import { Request } from 'express';

@Injectable()
export abstract class CoreAuthClientPort {
  abstract auth(authRequest: AuthRequest, req: Request): Promise<void>;
}
