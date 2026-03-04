import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule, ConfigService } from '@nestjs/config';

export const {{FEATURE_PASCAL}}MongooseRootImport = MongooseModule.forRootAsync({
  imports: [ConfigModule],
  inject: [ConfigService],
  useFactory: (configService: ConfigService) => ({
    uri: configService.get<string>('APPMONGOSTRING') ?? 'APPMONGOSTRING NOT FOUND',
    dbName: '{{DB_NAME}}',
  }),
});
