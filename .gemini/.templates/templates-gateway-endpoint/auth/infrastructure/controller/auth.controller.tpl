import { Controller, Post, Body, HttpCode, Req } from '@nestjs/common';
import { AuthService } from '../../domain/auth.service';
import { ResponseDto } from '../../../../dto/response';
import { AuthRequestDto } from '../../domain/request';
import { RequestWithClientIp } from '../../../../commons/types/request-with-client-ip.interface';

@Controller('v1')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('auth')
  @HttpCode(200)
  async createToken(
    @Body() body: AuthRequestDto,
    @Req() req: RequestWithClientIp,
  ): Promise<ResponseDto> {
    return await this.auth.createToken(body, req);
  }
}
