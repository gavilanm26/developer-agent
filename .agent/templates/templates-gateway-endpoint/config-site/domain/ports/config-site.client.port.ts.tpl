import { Injectable } from '@nestjs/common';
import { ResponseDto } from '@app/dto/response';
import { RequestDto } from '@app/dto/request';

@Injectable()
export abstract class ConfigSiteClientPort {
  abstract get(requestDto: RequestDto): Promise<ResponseDto>;
}
