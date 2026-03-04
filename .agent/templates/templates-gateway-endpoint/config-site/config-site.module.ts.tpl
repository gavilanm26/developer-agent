import { Module } from '@nestjs/common';
import { ConfigSiteUsecase } from './application/ports/config-site.usecase';
import { ConfigSiteClientPort } from './domain/ports/config-site.client.port';
import { SiteConfigServiceImpl } from './application/site-config.service.impl';
import { MsIdentityConfigRestClient } from './infrastructure/adapters/outbound/clients/ms-identity-config.rest.client';
import { ConfigSiteController } from './infrastructure/adapters/inbound/http/config-site.controller';
import { HttpModule } from '@nestjs/axios';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [ConfigModule.forRoot(), HttpModule],
  controllers: [ConfigSiteController],
  providers: [
    { provide: ConfigSiteUsecase, useClass: SiteConfigServiceImpl },
    { provide: ConfigSiteClientPort, useClass: MsIdentityConfigRestClient },
  ],
})
export class ConfigSiteModule {}
