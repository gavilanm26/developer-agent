import { HttpException, Injectable } from '@nestjs/common';
import { GoogleReCaptchaClientPort } from '@modules/re-captcha/domain/ports/google-re-captcha.client.port';
import { ReCaptchaUsecase } from '@modules/re-captcha/application/ports/re-captcha.usecase';
import { ReCaptchaResponseModel } from '@modules/re-captcha/domain/models/re-captcha-response.model';
import { Request } from 'express';

@Injectable()
export class VerifyReCaptchaUseCase implements ReCaptchaUsecase {
  public constructor(private readonly captcha: GoogleReCaptchaClientPort) {}

  async verify(token: string, req: Request): Promise<void> {
    const verify: ReCaptchaResponseModel = await this.captcha.verify(token, req);
    if (!verify.success) {
      throw new HttpException('reCAPTCHA validation failed', 400);
    }
  }
}
