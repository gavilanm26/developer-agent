import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { TokenAdapter } from './adapter/token.adapter';

@Module({
  imports: [HttpModule],
  providers: [TokenAdapter],
  exports: [TokenAdapter],
})
export class TokenModule {}
