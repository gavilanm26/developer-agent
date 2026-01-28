import { Test, TestingModule } from '@nestjs/testing';
import { HealthController } from './health.controller';

describe('HealthController', () => {
  let controller: HealthController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [HealthController],
    }).compile();

    controller = module.get<HealthController>(HealthController);
  });

  describe('health', () => {
    it('should return status "OK" and current time', async () => {
      const result = await controller.health();

      expect(result).toHaveProperty('status', 'OK');
      expect(result).toHaveProperty('time');
      expect(typeof result.time).toBe('number');
    });
  });
});
