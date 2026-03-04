import { Controller, Post, Body, HttpCode, Req } from '@nestjs/common';
import { AuthUsecase } from '../../../../application/ports/auth.usecase';
import { ResponseDto } from '@app/dto/response';
import { AuthRequestDto } from '../../../../domain/request';
import type { RequestWithClientIp } from '../../../../../../commons/types/request-with-client-ip.interface';

@Controller('v1')
export class AuthController {
  constructor(private readonly auth: AuthUsecase) {}

  @Post('auth')
  @HttpCode(200)
  createToken(
    @Body() body: AuthRequestDto,
    @Req() req: RequestWithClientIp,
  ): Promise<ResponseDto> {
    return this.auth.createToken(body, req);
  }
}
