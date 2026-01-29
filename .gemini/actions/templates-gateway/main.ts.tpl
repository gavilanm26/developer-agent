import * as dotenv from 'dotenv';
dotenv.config();

import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { json, urlencoded } from 'express';
import { ConfigService } from '@nestjs/config';
import { ExpressAdapter } from '@nestjs/platform-express';
import { Express, Request, Response, NextFunction } from 'express';

import { OpenTelemetryConfig } from './commons/otel.config';
import { GrafanaLoggerConfig } from './commons/http-logger/grafanaLogger.config';
import { corsValue } from './commons/cors/cors.config';
import { HeadersInterceptor } from './commons/interceptor/headers.interceptor';
import { requiredHeaders } from './commons/headers.constants';

async function bootstrap() {
  OpenTelemetryConfig.initialize();

  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'debug', 'verbose'],
  });

  const httpAdapter = app.getHttpAdapter() as ExpressAdapter;
  const expressApp: Express = httpAdapter.getInstance();

  expressApp.set('trust proxy', true);
  expressApp.disable('x-powered-by');

  expressApp.use((_req: Request, res: Response, next: NextFunction) => {
    res.removeHeader('Date');
    res.removeHeader('Last-Modified');
    next();
  });

  app.enableCors();
  app.useGlobalPipes(new ValidationPipe());

  app.use(json({ limit: '15mb' }));
  app.use(urlencoded({ limit: '15mb', extended: true }));

  const port: number = app.get(ConfigService).get('PORT', 3000);
  await app.listen(port);
  console.log(`🚀 Gateway running on port ${port}`);
}

bootstrap();
