import { Injectable } from '@nestjs/common';
import { Request } from 'express';

@Injectable()
export abstract class ReCaptchaUsecase {
  abstract verify(token: string, req: Request): Promise<void>;
}
