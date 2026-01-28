import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';

import { {{ENDPOINT_PASCAL}}Controller } from './infrastructure/controller/{{ENDPOINT_NAME}}.controller';
import { {{ENDPOINT_PASCAL}}Service } from './domain/{{ENDPOINT_NAME}}.service';
import { {{ENDPOINT_PASCAL}}Adapter } from './domain/{{ENDPOINT_NAME}}.adapter';

import { {{ENDPOINT_PASCAL}}ImplService } from './application/{{ENDPOINT_NAME}}.impl.service';
import { Ms{{ENDPOINT_PASCAL}}Adapter } from './infrastructure/adapter/ms-{{ENDPOINT_NAME}}.adapter';

@Module({
  imports: [HttpModule],
  controllers: [{{ENDPOINT_PASCAL}}Controller],
  providers: [
    { provide: {{ENDPOINT_PASCAL}}Service, useClass: {{ENDPOINT_PASCAL}}ImplService },
    { provide: {{ENDPOINT_PASCAL}}Adapter, useClass: Ms{{ENDPOINT_PASCAL}}Adapter },
  ],
})
export class {{MODULE_CLASS}} {}
