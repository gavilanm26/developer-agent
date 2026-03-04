import { Request } from 'express';
import { RequestDto } from '../../../dto/request';
import { ResponseDto } from '../../../dto/response';

export abstract class {{SERVICE_PASCAL}}ClientPort {
  abstract execute(payload: RequestDto, req: Request): Promise<ResponseDto>;
}
