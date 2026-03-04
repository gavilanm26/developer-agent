import { ConfigService } from '@nestjs/config';
import { Inject, Injectable } from '@nestjs/common';
import * as Redis from 'ioredis';

import { {{ENTITY_PASCAL}}CachePort } from '../../../../domain/ports/{{ENTITY_KEBAB}}.cache.port';

@Injectable()
export class Redis{{ENTITY_PASCAL}}CacheImpl implements {{ENTITY_PASCAL}}CachePort {
  private readonly ttlTime: number;

  constructor(
    @Inject('{{REDIS_TOKEN}}') private readonly redis: Redis.Redis,
    private readonly configService: ConfigService,
  ) {
    this.ttlTime = this.configService.get<number>('INFRAREDISTTL') || 1800;
  }

  async get(key: string): Promise<string | null> {
    return await this.redis.get(key);
  }

  async set(key: string, value: string): Promise<void> {
    await this.redis.set(key, value, 'EX', this.ttlTime);
  }
}
