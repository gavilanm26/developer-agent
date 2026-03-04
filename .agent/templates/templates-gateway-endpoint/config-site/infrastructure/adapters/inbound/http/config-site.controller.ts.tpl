import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Post,
  UseGuards,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import { ConfigSiteUsecase } from '../../../../application/ports/config-site.usecase';
import { ResponseDto } from '@app/dto/response';
import { RequestDto } from '@app/dto/request';
import { JwtAuthGuard } from '@auth/infrastructure/adapters/inbound/http/security/guard/auth.guard';

@Controller('v1')
@UseGuards(JwtAuthGuard)
@UsePipes(new ValidationPipe())
export class ConfigSiteController {
  constructor(private readonly config: ConfigSiteUsecase) {}

  @Post('site')
  @HttpCode(HttpStatus.OK)
  get(@Body() body: RequestDto): Promise<ResponseDto> {
    return this.config.get(body);
  }
}
