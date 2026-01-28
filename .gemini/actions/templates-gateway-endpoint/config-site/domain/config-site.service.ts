import { Injectable } from '@nestjs/common';
import { ResponseDto } from '../../../dto/response';
import { RequestDto } from '../../../dto/request';

import { Request } from 'express';

@Injectable()
export abstract class ConfigSiteService {
  abstract getConfig(requestDto: RequestDto, req: Request): Promise<ResponseDto>;
}
