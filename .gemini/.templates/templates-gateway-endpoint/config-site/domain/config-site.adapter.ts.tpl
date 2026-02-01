import { Injectable } from '@nestjs/common';
import { ResponseDto } from '../../../dto/response';
import { RequestDto } from '../../../dto/request';

@Injectable()
export abstract class ConfigSiteAdapter {
  abstract get(requestDto: RequestDto): Promise<ResponseDto>;
}
