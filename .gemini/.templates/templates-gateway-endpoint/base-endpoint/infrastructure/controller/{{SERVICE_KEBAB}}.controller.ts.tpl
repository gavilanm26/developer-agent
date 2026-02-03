import {
  Controller,
  Post,
  Body,
  Req,
} from '@nestjs/common';
import { Request } from 'express';

import { {{SERVICE_PASCAL}}Service } from '../../domain/{{SERVICE_KEBAB}}.service';
import { ResponseDto } from '../../../../dto/response';
import { RequestDto } from '../../../../dto/request';

@Controller('/v1')
export class {{SERVICE_PASCAL}}Controller {
  constructor(
    private readonly service{{SERVICE_PASCAL}}: {{SERVICE_PASCAL}}Service,
  ) {}

  @Post('/{{ROUTE_PATH}}')
  async execute(
    @Body() body: RequestDto,
    @Req() req: Request,
  ): Promise<ResponseDto> {
    return this.service{{SERVICE_PASCAL}}.execute(body, req);
  }
}
