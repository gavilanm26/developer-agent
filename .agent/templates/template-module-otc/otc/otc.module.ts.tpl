import { Module } from '@nestjs/common';
import { GenerateModule } from './generate/generate.module';
import { ValidateModule } from './validate/validate.module';

@Module({
  imports: [GenerateModule, ValidateModule],
})
export class OtcModule {}
