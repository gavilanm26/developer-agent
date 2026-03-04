import { Injectable } from '@nestjs/common';
import { AuthUsecase } from '@modules/auth/application/ports/auth.usecase';
import { CoreAuthClientPort } from '@modules/auth/domain/ports/core-auth.client.port';
import { AuthRequest } from '@modules/auth/domain/models/auth-request.model';
import { ReCaptchaUsecase } from '@modules/re-captcha/application/ports/re-captcha.usecase';
import { AuthCachePort } from '@modules/auth/domain/ports/auth-cache.port';
import { Request } from 'express';

@Injectable()
export class AuthTokenUseCase implements AuthUsecase {
  public constructor(
    private readonly authRepository: CoreAuthClientPort,
    private readonly captcha: ReCaptchaUsecase,
    private readonly authCache: AuthCachePort,
  ) {}

  async token(request: AuthRequest, req: Request): Promise<void> {
    await this.captcha.verify(request.tokenRecaptcha, req);

    await this.authRepository.auth(request, req);

    await this.authCache.set(request.documentNumber);
  }
}
