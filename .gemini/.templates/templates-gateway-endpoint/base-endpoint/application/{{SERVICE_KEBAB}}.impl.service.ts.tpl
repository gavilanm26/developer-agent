import { Injectable } from '@nestjs/common';
import { Request } from 'express';

import { {{SERVICE_PASCAL}}Service } from '../domain/{{SERVICE_KEBAB}}.service';
import { ResponseDto } from '../../../../dto/response';
import { RequestDto } from '../../../../dto/request';

@Injectable()
export class {{SERVICE_PASCAL}}ImplService {
  constructor(
    private readonly service: {{SERVICE_PASCAL}}Service,
  ) {}

  async execute(
    data: RequestDto,
    req: Request,
  ): Promise<ResponseDto> {
    return this.service.{{METHOD_NAME}}(data, req);
  }
}
