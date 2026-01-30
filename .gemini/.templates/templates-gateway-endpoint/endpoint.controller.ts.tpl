import { Body, Controller, {{HTTP_METHOD}}, Req } from '@nestjs/common';
import type { Request } from 'express';
import { {{ENDPOINT_PASCAL}}Service } from '../../domain/{{ENDPOINT_NAME}}.service';
import { {{ENDPOINT_PASCAL}}Dto } from '../dto/{{ENDPOINT_NAME}}.dto';

@Controller('{{ENDPOINT_NAME}}')
export class {{ENDPOINT_PASCAL}}Controller {
  constructor(private readonly service: {{ENDPOINT_PASCAL}}Service) {}

  @{{HTTP_METHOD}}('{{ROUTE_PATH}}')
  async {{METHOD_NAME}}(@Body() body: {{ENDPOINT_PASCAL}}Dto, @Req() req: Request) {
    return await this.service.{{METHOD_NAME}}(body as any, req);
  }
}
