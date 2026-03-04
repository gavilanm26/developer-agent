import { TokenAdapter } from '@commons/token/adapter/token.adapter';
import { Injectable } from '@nestjs/common';

@Injectable()
export class AuthTokenCommonsClient {
  constructor(private readonly tokenCore: TokenAdapter) {}
  async get() {
    return await this.tokenCore.get();
  }
}
