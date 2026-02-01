import { Injectable } from '@nestjs/common';
import { Request } from 'express';

import { {{SERVICE_PASCAL}}Adapter } from './{{SERVICE_KEBAB}}.adapter';
import { ResponseDto } from '../../../dto/response';
import { RequestDto } from '../../../dto/request';

@Injectable()
export class {{SERVICE_PASCAL}}Service {
  constructor(
    private readonly adapter: {{SERVICE_PASCAL}}Adapter,
  ) {}

  async {{METHOD_NAME}}(
    data: RequestDto,
    req: Request,
  ): Promise<ResponseDto> {
    return this.adapter.{{METHOD_NAME}}(data, req);
  }
}
