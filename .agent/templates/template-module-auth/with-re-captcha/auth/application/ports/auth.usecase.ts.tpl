import { Injectable } from '@nestjs/common';
import { AuthRequest } from '@modules/auth/domain/models/auth-request.model';
import { Request } from 'express';

@Injectable()
export abstract class AuthUsecase {
  abstract token(authRequest: AuthRequest, req: Request): Promise<void>;
}
