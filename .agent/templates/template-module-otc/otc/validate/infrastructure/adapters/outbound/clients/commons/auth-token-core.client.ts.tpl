import { Injectable } from '@nestjs/common';
import { TokenAdapter } from '@commons/token/adapter/token.adapter';

@Injectable()
export class AuthTokenCoreClient {
  constructor(private readonly tokenCore: TokenAdapter) {}

  async get() {
    return await this.tokenCore.get();
  }
}
