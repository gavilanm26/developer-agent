import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './commons/filters/all-exceptions.filter';
import { OpenTelemetryConfig } from './commons/otel.config';
import { ValidationPipe } from '@nestjs/common';
import helmet from 'helmet';
import { json, urlencoded } from 'express';
import { ConfigService } from '@nestjs/config';
import { GrafanaLoggerConfig } from './commons/http-logger/grafanaLogger.config';

async function bootstrap() {
  OpenTelemetryConfig.initialize();

  const app = await NestFactory.create(AppModule, {
    logger: new GrafanaLoggerConfig(),
  });
  app.useGlobalFilters(new AllExceptionsFilter());
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  app.use(helmet());
  app.use(json({ limit: '15mb' }));
  app.use(
    urlencoded({
      limit: '15mb',
      extended: true,
    }),
  );

  const port: number = app.get(ConfigService).get('PORT', 3000);
  await app.listen(port);
}
bootstrap();
