import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { TokenUsecase } from '../../../../../../application/ports/token.usecase';
import { AuthRequestDto } from '../../../../../../domain/request';
import { ResponseDto } from '@app/dto/response';
import { MsIdentityAuthRestClient } from '../../../../outbound/clients/ms-identity-auth.rest.client';
import { Request } from 'express';
import Crypto from '../../../../../../../../commons/crypto/crypto';
import jwtConfig from '../../../../../../domain/jwt.config';

@Injectable()
export class TokenGuard implements TokenUsecase {
  constructor(
    private readonly jwtService: JwtService,
    private readonly auth: MsIdentityAuthRestClient,
  ) {}

  async sign(payload: AuthRequestDto, req: Request): Promise<ResponseDto> {
    const response = await this.auth.validate(payload, req);
    if (response.status === 200) {
      const token = await this.jwtService.signAsync(
        {
          id: Crypto.encrypt(
            payload.data.documentNumber.toString(),
            process.env.APPENCRYPTJWT,
          ),
        },
        {
          algorithm: jwtConfig.algorithm,
          privateKey: jwtConfig.privateKey,
        },
      );
      return { response: token };
    }

    throw new HttpException('invalid data', HttpStatus.UNPROCESSABLE_ENTITY);
  }
}
