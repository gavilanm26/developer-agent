import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import Crypto from '../../../commons/crypto/crypto';

@Injectable()
export class TokenKycService {
  constructor(private readonly jwtService: JwtService) {}

  async signToken(documentNumber: string) {
    const token = await this.jwtService.signAsync({
      id: Crypto.encrypt(documentNumber.toString(), process.env.APPENCRYPTJWT),
    });
    return { response: token };
  }
}
