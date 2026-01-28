import { LoggerService, Injectable } from '@nestjs/common';

@Injectable()
export class GrafanaLoggerConfig implements LoggerService {
  log() {}

  fatal(message: any, ...optionalParams: any[]) {
    console.error(
      JSON.stringify({
        level: 'fatal',
        class: optionalParams[0],
        message,
      }),
    );
  }

  error(message: any, ...optionalParams: any[]) {
    console.error(
      JSON.stringify({
        level: 'error',
        class: optionalParams[1],
        code: message.code,
        processId: message.processId,
        document: message.document,
        response: message.response,
        request: message.request,
        headers: message.headers,
      }),
    );
  }

  warn(message: any, ...optionalParams: any[]) {
    console.warn(
      JSON.stringify({
        level: 'warn',
        class: optionalParams[0],
        message,
      }),
    );
  }

  debug?(message: any, ...optionalParams: any[]) {
    console.debug(
      JSON.stringify({
        level: 'debug',
        class: optionalParams[0],
        message,
      }),
    );
  }

  verbose?(message: any, ...optionalParams: any[]) {
    console.debug(
      JSON.stringify({
        level: 'verbose',
        class: optionalParams[0],
        code: message.code,
        processId: message.processId,
        document: message.document,
        response: message.response,
        request: message.request,
        headers: message.headers,
      }),
    );
  }
}
