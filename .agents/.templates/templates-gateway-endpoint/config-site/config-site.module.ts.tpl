import { Module } from '@nestjs/common';
import { ConfigSiteService } from './domain/config-site.service';
import { ConfigSiteAdapter } from './domain/config-site.adapter';
import { SiteConfigServiceImpl } from './application/site-config.service.impl';
import { MsIdentityConfigAdapter } from './infrastructure/adapter/ms-identity-config.adapter';
import { ConfigSiteController } from './infrastructure/controller/config-site.controller';
import { HttpModule } from '@nestjs/axios';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [ConfigModule.forRoot(), HttpModule],
  controllers: [ConfigSiteController],
  providers: [
    { provide: ConfigSiteService, useClass: SiteConfigServiceImpl },
    { provide: ConfigSiteAdapter, useClass: MsIdentityConfigAdapter },
  ],
})
export class ConfigSiteModule {}
