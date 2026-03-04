import { Injectable } from '@nestjs/common';
import { ReCaptchaResponseModel } from '@modules/re-captcha/domain/models/re-captcha-response.model';
import { Request } from 'express';

@Injectable()
export abstract class GoogleReCaptchaClientPort {
  abstract verify(token: string, req: Request): Promise<ReCaptchaResponseModel>;
}
