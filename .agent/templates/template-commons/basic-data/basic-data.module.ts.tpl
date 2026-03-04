import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';

import { GetBasicDataImplAdapter } from './adapter/get-basic-data.impl.adapter';

@Module({
  imports: [HttpModule],
  providers: [GetBasicDataImplAdapter],
  exports: [GetBasicDataImplAdapter],
})
export class BasicDataModule {}
