import { Body, Controller, HttpCode, Post, Req } from '@nestjs/common';
import { ConfigSiteService } from '../../domain/config-site.service';
import { ResponseDto } from '../../../../dto/response';
import { RequestDto } from '../../../../dto/request';
import type { Request } from 'express';

@Controller('v1')
export class ConfigSiteController {
  public constructor(private readonly config: ConfigSiteService) {}

  @Post('/site')
  @HttpCode(200)
  async getConfig(
    @Body() body: RequestDto,
    @Req() req: Request,
  ): Promise<ResponseDto> {
    return await this.config.getConfig(body, req);
  }
}
