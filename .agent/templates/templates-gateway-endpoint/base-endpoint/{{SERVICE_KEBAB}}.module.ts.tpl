import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';

import { {{SERVICE_PASCAL}}Controller } from './infrastructure/adapters/inbound/http/{{SERVICE_KEBAB}}.controller';
import { {{SERVICE_PASCAL}}Usecase } from './application/ports/{{SERVICE_KEBAB}}.usecase.port';
import { {{SERVICE_PASCAL}}UseCase } from './application/use-cases/{{SERVICE_KEBAB}}.usecase';
import { {{SERVICE_PASCAL}}ClientPort } from './domain/ports/{{SERVICE_KEBAB}}.client.port';
import { {{SERVICE_PASCAL}}RestClient } from './infrastructure/adapters/outbound/clients/microservices/{{SERVICE_KEBAB}}.rest.client';

@Module({
  imports: [HttpModule],
  controllers: [{{SERVICE_PASCAL}}Controller],
  providers: [
    {
      provide: {{SERVICE_PASCAL}}Usecase,
      useClass: {{SERVICE_PASCAL}}UseCase,
    },
    {
      provide: {{SERVICE_PASCAL}}ClientPort,
      useClass: {{SERVICE_PASCAL}}RestClient,
    },
  ],
})
export class {{SERVICE_PASCAL}}Module {}
