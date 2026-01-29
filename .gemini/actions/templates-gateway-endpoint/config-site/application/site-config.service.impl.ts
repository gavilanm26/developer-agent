import { Injectable } from '@nestjs/common';
import { ConfigSiteService } from '../domain/config-site.service';
import { ConfigSiteAdapter } from '../domain/config-site.adapter';
import { ResponseDto } from '../../../dto/response';
import { RequestDto } from '../../../dto/request';

@Injectable()
export class SiteConfigServiceImpl implements ConfigSiteService {
  public constructor(private readonly config: ConfigSiteAdapter) {}

  get(requestDto: RequestDto): Promise<ResponseDto> {
    return this.config.get(requestDto);
  }
}
