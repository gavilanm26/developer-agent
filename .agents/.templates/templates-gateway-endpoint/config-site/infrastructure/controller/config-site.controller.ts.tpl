import { Body, Controller, HttpCode, Post } from '@nestjs/common';
import { ConfigSiteService } from '../../domain/config-site.service';
import { ResponseDto } from '../../../../dto/response';
import { RequestDto } from '../../../../dto/request';

@Controller('v1')
export class ConfigSiteController {
  public constructor(private readonly config: ConfigSiteService) {}

  @Post('/site')
  @HttpCode(200)
  async get(@Body() body: RequestDto): Promise<ResponseDto> {
    return await this.config.get(body);
  }
}
