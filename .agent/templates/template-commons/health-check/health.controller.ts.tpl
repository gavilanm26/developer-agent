import { Controller, Get } from '@nestjs/common/decorators';

@Controller('health')
export class HealthController {
  @Get()
  health(): { status: string; time: number } {
    return {
      status: 'OK',
      time: Date.now(),
    };
  }
}
