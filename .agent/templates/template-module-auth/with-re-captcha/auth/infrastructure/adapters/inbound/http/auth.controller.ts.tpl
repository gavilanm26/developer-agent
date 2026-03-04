import {
  Body,
  Req,
  Controller,
  HttpCode,
  Post,
  UseInterceptors,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import { AuthUsecase } from '@modules/auth/application/ports/auth.usecase';
import { HeadersInterceptor } from '@commons/interceptor/headers.interceptor';
import { requiredHeaders } from '@commons/constants/headers.constants';
import { AuthHttpDto } from '@modules/auth/infrastructure/adapters/inbound/http/dto/auth.http.dto';
import type { Request } from 'express';

@Controller('v1')
export class AuthController {
  public constructor(private readonly auth: AuthUsecase) {}

  @Post('/auth')
  @HttpCode(200)
  @UsePipes(new ValidationPipe())
  @UseInterceptors(new HeadersInterceptor(requiredHeaders))
  token(@Body() body: AuthHttpDto, @Req() req: Request): Promise<void> {
    return this.auth.token(body, req);
  }
}
