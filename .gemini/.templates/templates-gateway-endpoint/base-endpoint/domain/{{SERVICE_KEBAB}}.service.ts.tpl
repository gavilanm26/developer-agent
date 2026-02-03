import { Request } from 'express';
import { ResponseDto } from '../../../dto/response';
import { RequestDto } from '../../../dto/request';

export abstract class {{SERVICE_PASCAL}}Service {
  abstract {{METHOD_NAME}}(
    data: RequestDto,
    req: Request,
  ): Promise<ResponseDto>;
}