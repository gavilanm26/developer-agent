import { Test } from '@nestjs/testing';
import * as Redis from 'ioredis';
import { RedisAuthCacheImpl } from '@modules/auth/infrastructure/adapters/outbound/cache/redis-auth.cache.impl';
import { ConfigService } from '@nestjs/config';

jest.mock('ioredis', () => ({
  Redis: jest.fn().mockImplementation(() => ({
    get: jest.fn(),
    set: jest.fn(),
  })),
}));

describe('RedisAuthCacheImpl', () => {
  let redis: RedisAuthCacheImpl;
  let mockRedis: jest.Mocked<Redis.Redis>;
  let mockConfigService: jest.Mocked<ConfigService>;

  beforeEach(async () => {
    mockConfigService = {
      get: jest.fn().mockReturnValue(1800),
    } as unknown as jest.Mocked<ConfigService>;

    const moduleRef = await Test.createTestingModule({
      providers: [
        RedisAuthCacheImpl,
        { provide: 'REDIS', useValue: new Redis.Redis() },
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    redis = moduleRef.get<RedisAuthCacheImpl>(RedisAuthCacheImpl);
    mockRedis = moduleRef.get('REDIS');
  });

  it('should set data to Redis', async () => {
    await redis.set('documentNumber');

    expect(mockRedis.set.mock.calls[0]).toEqual([
      'ac-documentNumber',
      'OK',
      'EX',
      1800,
    ]);
  });
});
