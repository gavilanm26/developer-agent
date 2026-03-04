import { Injectable } from '@nestjs/common';
import { Request } from 'express';
import { RequestDto } from '../../../dto/request';
import { ResponseDto } from '../../../dto/response';
import { {{SERVICE_PASCAL}}Usecase } from '../ports/{{SERVICE_KEBAB}}.usecase.port';
import { {{SERVICE_PASCAL}}ClientPort } from '../../domain/ports/{{SERVICE_KEBAB}}.client.port';

@Injectable()
export class {{SERVICE_PASCAL}}UseCase implements {{SERVICE_PASCAL}}Usecase {
  public constructor(private readonly client: {{SERVICE_PASCAL}}ClientPort) {}

  async execute(requestDto: RequestDto, req: Request): Promise<ResponseDto> {
    return await this.client.execute(requestDto, req);
  }
}
