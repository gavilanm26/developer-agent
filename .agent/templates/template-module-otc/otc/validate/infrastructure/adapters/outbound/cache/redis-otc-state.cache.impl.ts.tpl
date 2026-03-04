import { Inject, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as Redis from 'ioredis';

import { OtcStateCachePort } from '../../../../domain/ports/otc-state.cache.port';

@Injectable()
export class RedisOtcStateCacheImpl implements OtcStateCachePort {
  private readonly ttlTime: number;

  constructor(
    @Inject('REDIS') private readonly redis: Redis.Redis,
    private readonly configService: ConfigService,
  ) {
    this.ttlTime = Number(this.configService.get<string>('INFRAREDISTTL')) || 3600;
  }

  async set(processId: string): Promise<void> {
    await this.redis.set(`otc-${processId}`, 'true', 'EX', this.ttlTime);
  }
}
