import { Module } from '@nestjs/common';
import { AuthController } from './infrastructure/adapters/inbound/http/auth.controller';
import { AuthUsecase } from './application/ports/auth.usecase';
import { AuthTokenUseCase } from './application/use-cases/auth-token.usecase';
import { CoreAuthClientPort } from './domain/ports/core-auth.client.port';
import { AuthCoreRestClient } from './infrastructure/adapters/outbound/clients/core/auth-core.rest.client';
import { httpModuleConfig } from '@commons/https-agent/https.config';
import { AuthTokenCommonsClient } from './infrastructure/adapters/outbound/clients/commons/auth-token-commons.client';
import { TokenModule } from '@commons/token/token.module';
import { SetDataMapper } from './infrastructure/adapters/outbound/mappers/set-data.mapper';
import { ConfigModule } from '@nestjs/config';
import { ReCaptchaModule } from '../re-captcha/re-captcha.module';
import { AuthCachePort } from './domain/ports/auth-cache.port';
import { RedisAuthCacheImpl } from './infrastructure/adapters/outbound/cache/redis-auth.cache.impl';
import { Redis } from 'ioredis';

@Module({
  imports: [
    ConfigModule.forRoot(),
    httpModuleConfig,
    TokenModule,
    ReCaptchaModule,
  ],
  controllers: [AuthController],
  providers: [
    SetDataMapper,
    AuthTokenCommonsClient,
    { provide: AuthUsecase, useClass: AuthTokenUseCase },
    { provide: CoreAuthClientPort, useClass: AuthCoreRestClient },
    { provide: AuthCachePort, useClass: RedisAuthCacheImpl },
    {
      provide: 'REDIS',
      useValue: new Redis({
        host: process.env.INFRAREDISHOST,
        port: Number(process.env.INFRAREDISPORT),
        password: process.env.INFRAREDISPASS,
        tls: {},
      }),
    },
  ],
})
export class AuthModule {}
