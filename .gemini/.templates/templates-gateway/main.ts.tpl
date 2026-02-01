import * as dotenv from 'dotenv';
dotenv.config();
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { OpenTelemetryConfig } from './commons/otel.config';
import { GrafanaLoggerConfig } from './commons/http-logger/grafanaLogger.config';
import { corsValue } from './commons/cors/cors.config';
import { ValidationPipe } from '@nestjs/common';
import { HeadersInterceptor } from './commons/interceptor/headers.interceptor';
import { requiredHeaders } from './commons/headers.constants';
import {
  CryptoRequestInterceptor,
  CryptoResponseInterceptor,
  // <<GQL
  CryptoRequestGraphqlInterceptor,
  // GQL>>
} from './commons/crypto/interceptor/crypto.interceptor';
import { json, urlencoded } from 'express';
import { ConfigService } from '@nestjs/config';
import { ExpressAdapter } from '@nestjs/platform-express';
import { Express, Request, Response, NextFunction } from 'express';
import { EncryptExceptionFilter } from './commons/filters/encrypt-exception.filter';
import { StatusCodeInterceptor } from './commons/interceptor/status-code.interceptor';
import { clientIpMiddleware } from './commons/middlewares/client-ip.middleware';

async function bootstrap() {
  OpenTelemetryConfig.initialize();

  const app = await NestFactory.create(AppModule, {
    logger: new GrafanaLoggerConfig(),
  });

  const corsOptions = {
    origin: corsValue(),
    methods: 'GET,PUT,PATCH,POST',
    preflightContinue: false,
    optionsSuccessStatus: 204,
  };

  const httpAdapter = app.getHttpAdapter() as ExpressAdapter;
  const expressApp: Express = httpAdapter.getInstance();

  expressApp.set('trust proxy', true);

  expressApp.use(clientIpMiddleware);

  expressApp.disable('x-powered-by');

  expressApp.use((_req: Request, res: Response, next: NextFunction) => {
    res.removeHeader('Date');
    res.removeHeader('Last-Modified');
    next();
  });
  app.useGlobalFilters(new EncryptExceptionFilter());

  app.enableCors(corsOptions);
  app.useGlobalPipes(new ValidationPipe());
  app.useGlobalInterceptors(
    new HeadersInterceptor(requiredHeaders),
    new CryptoRequestInterceptor(),
    new CryptoResponseInterceptor(),
    // <<GQL
    new CryptoRequestGraphqlInterceptor(),
    // GQL>>
    new StatusCodeInterceptor(),
  );
  app.use(json({ limit: '15mb' }));
  app.use(urlencoded({ limit: '15mb', extended: true }));

  const port: number = app.get(ConfigService).get('PORT', 3000);
  await app.listen(port);
}

bootstrap();