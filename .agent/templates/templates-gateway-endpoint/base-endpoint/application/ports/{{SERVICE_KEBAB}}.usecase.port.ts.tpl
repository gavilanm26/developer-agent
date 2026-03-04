import { Request } from 'express';
import { RequestDto } from '../../../dto/request';
import { ResponseDto } from '../../../dto/response';

export abstract class {{SERVICE_PASCAL}}Usecase {
  abstract execute(requestDto: RequestDto, req: Request): Promise<ResponseDto>;
}
