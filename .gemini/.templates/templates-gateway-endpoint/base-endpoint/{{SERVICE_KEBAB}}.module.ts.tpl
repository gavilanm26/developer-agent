import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';

import { {{SERVICE_PASCAL}}Controller } from './infrastructure/controller/{{SERVICE_KEBAB}}.controller';
import { {{SERVICE_PASCAL}}Service } from './domain/{{SERVICE_KEBAB}}.service';
import { {{SERVICE_PASCAL}}ImplService } from './application/{{SERVICE_KEBAB}}.impl.service';
import { {{SERVICE_PASCAL}}Adapter } from './domain/{{SERVICE_KEBAB}}.adapter';
import { Ms{{SERVICE_PASCAL}}Adapter } from './infrastructure/adapter/ms-{{SERVICE_KEBAB}}.adapter';

@Module({
  imports: [HttpModule],
  controllers: [{{SERVICE_PASCAL}}Controller],
  providers: [
    {
      provide: {{SERVICE_PASCAL}}Service,
      useClass: {{SERVICE_PASCAL}}ImplService,
    },
    {
      provide: {{SERVICE_PASCAL}}Adapter,
      useClass: Ms{{SERVICE_PASCAL}}Adapter,
    },
  ],
})
export class {{SERVICE_PASCAL}}Module {}
