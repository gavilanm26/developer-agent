import { Test } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import * as Redis from 'ioredis';

import { RedisOtcStateCacheImpl } from './redis-otc-state.cache.impl';

jest.mock('ioredis', () => ({
  Redis: jest.fn().mockImplementation(() => ({
    get: jest.fn(),
    set: jest.fn(),
  })),
}));

describe('RedisOtcStateCacheImpl', () => {
  let cache: RedisOtcStateCacheImpl;
  let mockRedis: jest.Mocked<Redis.Redis>;
  let mockConfigService: jest.Mocked<ConfigService>;

  beforeEach(async () => {
    const moduleRef = await Test.createTestingModule({
      providers: [
        RedisOtcStateCacheImpl,
        { provide: 'REDIS', useValue: new Redis.Redis() },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn().mockReturnValue('3600'),
          },
        },
      ],
    }).compile();

    cache = moduleRef.get<RedisOtcStateCacheImpl>(RedisOtcStateCacheImpl);
    mockRedis = moduleRef.get('REDIS');
    mockConfigService = moduleRef.get(ConfigService);
  });

  it('should set data to Redis', async () => {
    const mockData = 'mockedData';
    await cache.set(mockData);

    expect(mockConfigService.get).toHaveBeenCalledWith('INFRAREDISTTL');
    expect(mockRedis.set).toHaveBeenCalledWith(
      'otc-mockedData',
      'true',
      'EX',
      3600,
    );
  });
});
