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
import { ValidateOtcUseCase } from '../../../../application/ports/validate-otc.usecase';
import { ValidateOtcHttpDto } from './dto/validate-otc.http.dto';

@Controller('v1')
@UsePipes(new ValidationPipe())
@UseInterceptors(new HeadersInterceptor(requiredHeaders))
export class ValidateOtcController {
  constructor(
    @Inject(ValidateOtcUseCase)
    private readonly otcUseCase: ValidateOtcUseCase,
  ) {}

  @Post('/validate-otc')
  @HttpCode(HttpStatus.OK)
  async validateOtc(
    @Body() body: ValidateOtcHttpDto,
    @Req() req: Request,
  ): Promise<void> {
    await this.otcUseCase.validate(body, req);
  }
}
