import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';

import { Redis{{ENTITY_PASCAL}}CacheImpl } from './redis-{{ENTITY_KEBAB}}.cache.impl';

describe('Redis{{ENTITY_PASCAL}}CacheImpl', () => {
  let adapter: Redis{{ENTITY_PASCAL}}CacheImpl;
  let redis: { get: jest.Mock; set: jest.Mock };
  const configService = { get: jest.fn() };

  beforeEach(async () => {
    redis = { get: jest.fn(), set: jest.fn() };
    configService.get.mockReturnValue(1800);

    const moduleRef: TestingModule = await Test.createTestingModule({
      providers: [
        Redis{{ENTITY_PASCAL}}CacheImpl,
        { provide: '{{REDIS_TOKEN}}', useValue: redis },
        { provide: ConfigService, useValue: configService },
      ],
    }).compile();

    adapter = moduleRef.get(Redis{{ENTITY_PASCAL}}CacheImpl);
  });

  it('should return null when cache miss', async () => {
    redis.get.mockResolvedValue(null);

    const result = await adapter.get('abc');

    expect(redis.get).toHaveBeenCalledWith('abc');
    expect(result).toBeNull();
  });

  it('should return cached value on hit', async () => {
    redis.get.mockResolvedValue('value-abc');

    const result = await adapter.get('abc');

    expect(result).toEqual('value-abc');
  });

  it('should store value with ttl', async () => {
    redis.set.mockResolvedValue('OK');

    await adapter.set('abc', 'value-abc');

    expect(redis.set).toHaveBeenCalledWith('abc', 'value-abc', 'EX', 1800);
  });
});
