import { Injectable } from '@nestjs/common';
import { ResponseDto } from '../../../dto/response';
import { RequestDto } from '../../../dto/request';

@Injectable()
export abstract class ConfigSiteService {
  abstract get(requestDto: RequestDto): Promise<ResponseDto>;
}
