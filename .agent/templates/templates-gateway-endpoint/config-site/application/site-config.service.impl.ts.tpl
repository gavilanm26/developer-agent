import { Injectable } from '@nestjs/common';
import { ConfigSiteUsecase } from './ports/config-site.usecase';
import { ConfigSiteClientPort } from '../domain/ports/config-site.client.port';
import { ResponseDto } from '@app/dto/response';
import { RequestDto } from '@app/dto/request';

@Injectable()
export class SiteConfigServiceImpl implements ConfigSiteUsecase {
  constructor(private readonly config: ConfigSiteClientPort) {}

  get(requestDto: RequestDto): Promise<ResponseDto> {
    return this.config.get(requestDto);
  }
}
