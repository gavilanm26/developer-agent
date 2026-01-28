import { Injectable } from '@nestjs/common';
import { Request } from 'express';
import { {{ENDPOINT_PASCAL}}Request } from './interfaces/{{ENDPOINT_NAME}}-request.interface';
import { {{ENDPOINT_PASCAL}}Response } from './interfaces/{{ENDPOINT_NAME}}-response.interface';

@Injectable()
export abstract class {{ENDPOINT_PASCAL}}Service {
  abstract {{METHOD_NAME}}(data: {{ENDPOINT_PASCAL}}Request, req: Request): Promise<{{ENDPOINT_PASCAL}}Response>;
}
