import { Injectable } from '@nestjs/common';
import { Request } from 'express';
import { {{ENDPOINT_PASCAL}}Service } from '../domain/{{ENDPOINT_NAME}}.service';
import { {{ENDPOINT_PASCAL}}Adapter } from '../domain/{{ENDPOINT_NAME}}.adapter';
import { {{ENDPOINT_PASCAL}}Request } from '../domain/interfaces/{{ENDPOINT_NAME}}-request.interface';
import { {{ENDPOINT_PASCAL}}Response } from '../domain/interfaces/{{ENDPOINT_NAME}}-response.interface';

@Injectable()
export class {{ENDPOINT_PASCAL}}ImplService implements {{ENDPOINT_PASCAL}}Service {
  constructor(private readonly adapter: {{ENDPOINT_PASCAL}}Adapter) {}

  async {{METHOD_NAME}}(data: {{ENDPOINT_PASCAL}}Request, req: Request): Promise<{{ENDPOINT_PASCAL}}Response> {
    return await this.adapter.{{METHOD_NAME}}(data, req);
  }
}
