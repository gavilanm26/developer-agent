import { Module } from '@nestjs/common';
import { ReCaptchaUsecase } from './application/ports/re-captcha.usecase';
import { VerifyReCaptchaUseCase } from './application/use-cases/verify-re-captcha.usecase';
import { GoogleReCaptchaClientPort } from './domain/ports/google-re-captcha.client.port';
import { GoogleReCaptchaRestClient } from './infrastructure/adapters/outbound/clients/google/google-re-captcha.rest.client';
import { SetDataMapper } from './infrastructure/adapters/outbound/mappers/set-data.mapper';
import { TokenModule } from '@commons/token/token.module';
import { httpModuleConfig } from '@commons/https-agent/https.config';

@Module({
  imports: [httpModuleConfig, TokenModule],
  providers: [
    SetDataMapper,
    { provide: ReCaptchaUsecase, useClass: VerifyReCaptchaUseCase },
    {
      provide: GoogleReCaptchaClientPort,
      useClass: GoogleReCaptchaRestClient,
    },
  ],
  exports: [ReCaptchaUsecase],
})
export class ReCaptchaModule {}
