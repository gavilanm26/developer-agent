import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import Redis from 'ioredis';

import { httpModuleConfig } from '@commons/https-agent/https.config';
import { TokenModule } from '@commons/token/token.module';
import { BasicDataModule } from '@commons/basic-data/basic-data.module';
import { ValidateOtcController } from './infrastructure/adapters/inbound/http/validate-otc.controller';
import { ValidateOtcUseCase } from './application/ports/validate-otc.usecase';
import { ValidateOtcService } from './application/use-cases/validate-otc.usecase';
import { ValidateOtcRequestMapper } from './application/mappers/validate-otc-request.mapper';
import { ValidateOtcRepositoryPort } from './domain/ports/validate-otc.repository.port';
import { BasicDataClientPort } from './domain/ports/basic-data.client.port';
import { OtcStateCachePort } from './domain/ports/otc-state.cache.port';
import { AuthTokenCoreClient } from './infrastructure/adapters/outbound/clients/commons/auth-token-core.client';
import { GetBasicDataClient } from './infrastructure/adapters/outbound/clients/commons/get-basic-data.client';
import { ValidateOtcRestClient } from './infrastructure/adapters/outbound/clients/core/validate-otc.rest.client';
import { RedisOtcStateCacheImpl } from './infrastructure/adapters/outbound/cache/redis-otc-state.cache.impl';
import { ValidateOtcMapper } from './infrastructure/adapters/outbound/mappers/validate-otc.mapper';

@Module({
  imports: [
    ConfigModule.forRoot(),
    httpModuleConfig,
    TokenModule,
    BasicDataModule,
  ],
  controllers: [ValidateOtcController],
  providers: [
    ValidateOtcMapper,
    ValidateOtcRequestMapper,
    AuthTokenCoreClient,
    {
      provide: ValidateOtcUseCase,
      useClass: ValidateOtcService,
    },
    {
      provide: ValidateOtcRepositoryPort,
      useClass: ValidateOtcRestClient,
    },
    {
      provide: BasicDataClientPort,
      useClass: GetBasicDataClient,
    },
    {
      provide: OtcStateCachePort,
      useClass: RedisOtcStateCacheImpl,
    },
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
export class ValidateModule {}
