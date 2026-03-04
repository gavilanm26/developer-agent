import { LoggerService, Injectable } from '@nestjs/common';

@Injectable()
export class GrafanaLoggerConfig implements LoggerService {
  private readonly nestContexts = [
    'NestFactory',
    'InstanceLoader',
    'RoutesResolver',
    'RouterExplorer',
    'NestApplication',
    'MongooseModule',
    'ConfigModule',
    'MongooseCoreModule',
  ];

  private isInternalLog(context: string): boolean {
    return this.nestContexts.includes(context);
  }

  private formatLog(level: string, message: any, context?: string) {
    if (context && this.isInternalLog(context)) return;

    const logObject: any = {
      level,
      class: context || 'Unknown',
    };

    if (typeof message === 'object') {
      Object.assign(logObject, message);
    } else {
      logObject.message = message;
    }

    console.log(JSON.stringify(logObject));
  }

  log(message: any, ...optionalParams: any[]) {
    this.formatLog('log', message, optionalParams[0]);
  }

  fatal(message: any, ...optionalParams: any[]) {
    const context = optionalParams[0];
    if (context && this.isInternalLog(context)) return;

    const logObject: any = {
      level: 'fatal',
      class: context || 'Unknown',
    };

    if (typeof message === 'object') {
      Object.assign(logObject, message);
    } else {
      logObject.message = message;
    }

    console.error(JSON.stringify(logObject));
  }

  error(message: any, ...optionalParams: any[]) {
    const context = optionalParams.reverse().find(param => typeof param === 'string') || 'Unknown';

    const logObject: any = {
      level: 'error',
      class: context,
    };

    if (typeof message === 'object') {
      Object.assign(logObject, message);
    } else {
      logObject.message = message;
    }

    console.error(JSON.stringify(logObject));
  }

  warn(message: any, ...optionalParams: any[]) {
    const context = optionalParams[0];
    if (context && this.isInternalLog(context)) return;

    const logObject: any = {
      level: 'warn',
      class: context || 'Unknown',
    };

    if (typeof message === 'object') {
      Object.assign(logObject, message);
    } else {
      logObject.message = message;
    }

    console.warn(JSON.stringify(logObject));
  }

  debug(message: any, ...optionalParams: any[]) {
    const context = optionalParams[0];
    if (context && this.isInternalLog(context)) return;

    const logObject: any = {
      level: 'debug',
      class: context || 'Unknown',
    };

    if (typeof message === 'object') {
      Object.assign(logObject, message);
    } else {
      logObject.message = message;
    }

    console.debug(JSON.stringify(logObject));
  }

  verbose(message: any, ...optionalParams: any[]) {
    const context = optionalParams[0];
    if (context && this.isInternalLog(context)) return;

    const logObject: any = {
      level: 'verbose',
      class: context || 'Unknown',
    };

    if (typeof message === 'object') {
      Object.assign(logObject, message);
    } else {
      logObject.message = message;
    }

    console.debug(JSON.stringify(logObject));
  }
}
