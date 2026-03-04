import { Injectable, UnauthorizedException } from '@nestjs/common';
import { Validate } from './use-case/validate';
import { TokenUsecase } from './ports/token.usecase';
import { AuthRequestDto } from '../domain/request';
import { AuthUsecase } from './ports/auth.usecase';
import { ResponseDto } from '@app/dto/response';
import { Request } from 'express';

@Injectable()
export class JwtAuthService implements AuthUsecase {
  constructor(
    private readonly token: TokenUsecase,
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
