import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { HttpModule } from '@nestjs/axios';
import { MongooseModule } from '@nestjs/mongoose';
import Redis from 'ioredis';

import { {{FEATURE_PASCAL}}Controller } from './infrastructure/adapters/inbound/http/{{FEATURE_KEBAB}}.controller';
import { {{FEATURE_PASCAL}}Usecase } from './application/ports/{{FEATURE_KEBAB}}.usecase';
import { {{FEATURE_PASCAL}}ApplicationService } from './application/{{FEATURE_KEBAB}}.impl.service';
import { Create{{ENTITY_PASCAL}}UseCase } from './application/use-cases/create-{{ENTITY_KEBAB}}.use-case';
import { Update{{ENTITY_PASCAL}}UseCase } from './application/use-cases/update-{{ENTITY_KEBAB}}.use-case';
import { Delete{{ENTITY_PASCAL}}UseCase } from './application/use-cases/delete-{{ENTITY_KEBAB}}.use-case';
import { Get{{ENTITY_PASCAL}}UseCase } from './application/use-cases/get-{{ENTITY_KEBAB}}.use-case';
import { {{ENTITY_PASCAL}}RepositoryPort } from './domain/ports/{{ENTITY_KEBAB}}.repository.port';
import { {{ENTITY_PASCAL}}CachePort } from './domain/ports/{{ENTITY_KEBAB}}.cache.port';
import { {{EXTERNAL_PASCAL}}ClientPort } from './domain/ports/{{EXTERNAL_KEBAB}}.client.port';
import { Mongo{{ENTITY_PASCAL}}RepositoryImpl } from './infrastructure/adapters/outbound/repositories/mongo-{{ENTITY_KEBAB}}.repository.impl';
import { Redis{{ENTITY_PASCAL}}CacheImpl } from './infrastructure/adapters/outbound/cache/redis-{{ENTITY_KEBAB}}.cache.impl';
import { {{EXTERNAL_PASCAL}}RestClient } from './infrastructure/adapters/outbound/clients/{{EXTERNAL_KEBAB}}.rest.client';
import { SetDataMapper } from './infrastructure/adapters/outbound/mappers/set-data.mapper';
import { {{MONGO_SCHEMA_PASCAL}}, {{MONGO_MODEL_CONST}} } from './infrastructure/persistence/schemas/{{ENTITY_KEBAB}}.schema';

@Module({
  imports: [
    ConfigModule.forRoot(),
    HttpModule,
    MongooseModule.forFeature([
      { name: {{MONGO_SCHEMA_PASCAL}}.name, schema: {{MONGO_MODEL_CONST}} },
    ]),
  ],
  controllers: [{{FEATURE_PASCAL}}Controller],
  providers: [
    Create{{ENTITY_PASCAL}}UseCase,
    Update{{ENTITY_PASCAL}}UseCase,
    Delete{{ENTITY_PASCAL}}UseCase,
    Get{{ENTITY_PASCAL}}UseCase,
    {
      provide: {{ENTITY_PASCAL}}RepositoryPort,
      useClass: Mongo{{ENTITY_PASCAL}}RepositoryImpl,
    },
    {
      provide: {{ENTITY_PASCAL}}CachePort,
      useClass: Redis{{ENTITY_PASCAL}}CacheImpl,
    },
    {
      provide: {{EXTERNAL_PASCAL}}ClientPort,
      useClass: {{EXTERNAL_PASCAL}}RestClient,
    },
    SetDataMapper,
    {
      provide: {{FEATURE_PASCAL}}Usecase,
      useClass: {{FEATURE_PASCAL}}ApplicationService,
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
  exports: [{{FEATURE_PASCAL}}Usecase],
})
export class {{FEATURE_PASCAL}}Module {}
