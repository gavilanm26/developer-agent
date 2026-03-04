import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Inject,
  Post,
  Req,
  UseInterceptors,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import type { Request } from 'express';

import { HeadersInterceptor } from '@commons/interceptor/headers.interceptor';
import { requiredHeaders } from '@commons/constants/headers.constants';
import { GenerateOtcUseCase } from '../../../../application/ports/generate-otc.usecase';
import { GenerateOtcHttpDto } from './dto/generate-otc.http.dto';

@Controller('v1')
@UsePipes(new ValidationPipe())
@UseInterceptors(new HeadersInterceptor(requiredHeaders))
export class GenerateOtcController {
  constructor(
    @Inject(GenerateOtcUseCase)
    private readonly service: GenerateOtcUseCase,
  ) {}

  @Post('/generate-otc')
  @HttpCode(HttpStatus.OK)
  async generate(
    @Body() body: GenerateOtcHttpDto,
    @Req() req: Request,
  ): Promise<void> {
    await this.service.generate(body, req);
  }
}
