import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { httpModuleConfig } from '@commons/https-agent/https.config';
import { TokenModule } from '@commons/token/token.module';
import { BasicDataModule } from '@commons/basic-data/basic-data.module';
import { GenerateOtcUseCase } from './application/ports/generate-otc.usecase';
import { GenerateOtcService } from './application/use-cases/generate-otc.usecase';
import { GenerateOtcRequestMapper } from './application/mappers/generate-otc-request.mapper';
import { GenerateOtcClientPort } from './domain/ports/generate-otc.client.port';
import { BasicDataClientPort } from './domain/ports/basic-data.client.port';
import { GenerateOtcController } from './infrastructure/adapters/inbound/http/generate-otc.controller';
import { AuthTokenCoreClient } from './infrastructure/adapters/outbound/clients/commons/auth-token-core.client';
import { GetBasicDataClient } from './infrastructure/adapters/outbound/clients/commons/get-basic-data.client';
import { GenerateOtcRestClient } from './infrastructure/adapters/outbound/clients/core/generate-otc.rest.client';
import { GenerateOtcMapper } from './infrastructure/adapters/outbound/mappers/generate-otc.mapper';

@Module({
  imports: [
    ConfigModule.forRoot(),
    httpModuleConfig,
    TokenModule,
    BasicDataModule,
  ],
  providers: [
    GenerateOtcMapper,
    GenerateOtcRequestMapper,
    AuthTokenCoreClient,
    {
      provide: GenerateOtcUseCase,
      useClass: GenerateOtcService,
    },
    {
      provide: GenerateOtcClientPort,
      useClass: GenerateOtcRestClient,
    },
    {
      provide: BasicDataClientPort,
      useClass: GetBasicDataClient,
    },
  ],
  controllers: [GenerateOtcController],
})
export class GenerateModule {}
