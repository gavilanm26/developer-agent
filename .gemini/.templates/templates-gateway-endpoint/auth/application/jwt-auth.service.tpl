import { Injectable, UnauthorizedException } from '@nestjs/common';
import { Validate } from './use-case/validate';
import { TokenService } from '../domain/token.service';
import { AuthRequestDto } from '../domain/request';
import { AuthService } from '../domain/auth.service';
import { ResponseDto } from '../../../dto/response';
import { Request } from 'express';

@Injectable()
export class JwtAuthService implements AuthService {
  constructor(
    private readonly token: TokenService,
    private readonly validate: Validate,
  ) {}

  async createToken(
    payload: AuthRequestDto,
    req: Request,
  ): Promise<ResponseDto> {
    if (!this.validate.token(payload.data.value)) {
      throw new UnauthorizedException('Token no válido');
    }

    return this.token.sign(payload, req);
  }
}
