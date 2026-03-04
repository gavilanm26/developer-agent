import { Inject, Injectable } from '@nestjs/common';
import * as Redis from 'ioredis';
import { AuthCachePort } from '@modules/auth/domain/ports/auth-cache.port';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class RedisAuthCacheImpl implements AuthCachePort {
  private readonly ttlTime: number;

  constructor(
    @Inject('REDIS') private readonly redis: Redis.Redis,
    private readonly configService: ConfigService,
  ) {
    this.ttlTime = this.configService.get<number>('INFRAACHETTL') || 1800;
  }

  async set(documentNumber: string) {
    await this.redis.set('ac-' + documentNumber, 'OK', 'EX', this.ttlTime);
  }
}
