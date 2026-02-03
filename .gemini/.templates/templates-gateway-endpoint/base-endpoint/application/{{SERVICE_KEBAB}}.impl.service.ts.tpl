import { Injectable } from '@nestjs/common';
import { Request } from 'express';

import { {{SERVICE_PASCAL}}Service } from '../domain/{{SERVICE_PASCAL}}.Service';
import { {{SERVICE_PASCAL}}Adapter } from '../domain/{{SERVICE_PASCAL}}.Adapter';
import { ResponseDto } from '../../../dto/response';
import { RequestDto } from '../../../dto/request';

@Injectable()
export class {{SERVICE_PASCAL}}ImplService implements {{SERVICE_PASCAL}}Service{
  public constructor(
    private readonly adapter{{SERVICE_PASCAL}}: {{SERVICE_PASCAL}}Adapter,
  ) {}

  async execute(
    data: RequestDto,
    req: Request,
  ): Promise<ResponseDto> {
    return this.adapter{{SERVICE_PASCAL}}.{{METHOD_NAME}}(data, req);
  }
}
