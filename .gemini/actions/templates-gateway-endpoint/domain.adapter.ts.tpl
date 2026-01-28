import { Injectable } from '@nestjs/common';
import { Request } from 'express';
import { {{ENDPOINT_PASCAL}}Request } from './interfaces/{{ENDPOINT_NAME}}-request.interface';

@Injectable()
export abstract class {{ENDPOINT_PASCAL}}Adapter {
  abstract {{METHOD_NAME}}(data: {{ENDPOINT_PASCAL}}Request, req: Request): Promise<any>;
}
