import { Injectable } from '@nestjs/common';
import { ConfigSiteService } from '../domain/config-site.service';
import { ConfigSiteAdapter } from '../domain/config-site.adapter';
import { ResponseDto } from '../../../dto/response';
import { RequestDto } from '../../../dto/request';
import { Request } from 'express';

@Injectable()
export class SiteConfigServiceImpl implements ConfigSiteService {
  public constructor(private readonly config: ConfigSiteAdapter) {}

  getConfig(requestDto: RequestDto, req: Request): Promise<ResponseDto> {
    return this.config.getConfig(requestDto, req);
  }
}
