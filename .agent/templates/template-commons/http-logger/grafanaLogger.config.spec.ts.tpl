import { GrafanaLoggerConfig } from './grafanaLogger.config';

describe('GrafanaLoggerConfig', () => {
  let logger: GrafanaLoggerConfig;
  let consoleSpy: jest.SpyInstance;

  beforeEach(() => {
    logger = new GrafanaLoggerConfig();
    consoleSpy = jest.spyOn(console, 'error').mockImplementation();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('log', () => {
    it('should have empty log method', () => {
      expect(() => logger.log('test-message')).not.toThrow();
    });
  });

  describe('fatal', () => {
    it('should log fatal message with class', () => {
      const message = 'Critical system failure';
      const className = 'TestClass';

      logger.fatal(message, className);

      expect(consoleSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'fatal',
          class: className,
          message,
        }),
      );
    });

    it('should log fatal message with default class when not provided', () => {
      const message = 'Critical system failure';

      logger.fatal(message);

      expect(consoleSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'fatal',
          class: 'Unknown',
          message,
        }),
      );
    });

    it('should handle multiple optional parameters', () => {
      const message = 'Critical system failure';
      const className = 'TestClass';
      const additionalParam = 'extra info';

      logger.fatal(message, className, additionalParam);

      expect(consoleSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'fatal',
          class: className,
          message,
        }),
      );
    });
  });

  describe('error', () => {
    it('should log error message with all properties', () => {
      const errorMessage = {
        code: 'E001',
        processId: '12345',
        document: '123456789',
        response: 'Error response',
        request: 'Request data',
        headers: { 'content-type': 'application/json' },
      };
      const className = 'ErrorClass';

      logger.error(errorMessage, 'extra', className);

      expect(consoleSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'error',
          class: className,
          code: 'E001',
          processId: '12345',
          document: '123456789',
          response: 'Error response',
          request: 'Request data',
          headers: { 'content-type': 'application/json' },
        }),
      );
    });

    it('should log error message with default class when not provided', () => {
      const errorMessage = {
        code: 'E002',
        processId: '67890',
        document: '987654321',
        response: 'Another error',
        request: 'Another request',
        headers: { 'authorization': 'Bearer token' },
      };

      logger.error(errorMessage);

      expect(consoleSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'error',
          class: 'Unknown',
          code: 'E002',
          processId: '67890',
          document: '987654321',
          response: 'Another error',
          request: 'Another request',
          headers: { 'authorization': 'Bearer token' },
        }),
      );
    });

    it('should handle error message with missing properties', () => {
      const errorMessage = {
        code: 'E003',
        processId: '11111',
      };

      logger.error(errorMessage, 'extra', 'TestClass');

      expect(consoleSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'error',
          class: 'TestClass',
          code: 'E003',
          processId: '11111',
          document: undefined,
          response: undefined,
          request: undefined,
          headers: undefined,
        }),
      );
    });
  });

  describe('warn', () => {
    let warnSpy: jest.SpyInstance;

    beforeEach(() => {
      warnSpy = jest.spyOn(console, 'warn').mockImplementation();
    });

    it('should log warn message with class', () => {
      const message = 'Warning message';
      const className = 'WarningClass';

      logger.warn(message, className);

      expect(warnSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'warn',
          class: className,
          message,
        }),
      );
    });

    it('should log warn message with default class when not provided', () => {
      const message = 'Warning message';

      logger.warn(message);

      expect(warnSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'warn',
          class: 'Unknown',
          message,
        }),
      );
    });

    it('should handle multiple optional parameters', () => {
      const message = 'Warning message';
      const className = 'WarningClass';
      const additionalParam = 'extra info';

      logger.warn(message, className, additionalParam);

      expect(warnSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'warn',
          class: className,
          message,
        }),
      );
    });
  });

  describe('debug', () => {
    let debugSpy: jest.SpyInstance;

    beforeEach(() => {
      debugSpy = jest.spyOn(console, 'debug').mockImplementation();
    });

    it('should log debug message with class', () => {
      const message = 'Debug message';
      const className = 'DebugClass';

      logger.debug!(message, className);

      expect(debugSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'debug',
          class: className,
          message,
        }),
      );
    });

    it('should log debug message with default class when not provided', () => {
      const message = 'Debug message';

      logger.debug!(message);

      expect(debugSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'debug',
          class: 'Unknown',
          message,
        }),
      );
    });

    it('should handle multiple optional parameters', () => {
      const message = 'Debug message';
      const className = 'DebugClass';
      const additionalParam = 'extra info';

      logger.debug!(message, className, additionalParam);

      expect(debugSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'debug',
          class: className,
          message,
        }),
      );
    });
  });

  describe('verbose', () => {
    let verboseSpy: jest.SpyInstance;

    beforeEach(() => {
      verboseSpy = jest.spyOn(console, 'debug').mockImplementation();
    });

    it('should log verbose message with all properties', () => {
      const verboseMessage = {
        code: 'V001',
        processId: '54321',
        document: '111222333',
        response: 'Verbose response',
        request: 'Verbose request',
        headers: { 'x-custom': 'custom-value' },
      };
      const className = 'VerboseClass';

      logger.verbose!(verboseMessage, className);

      expect(verboseSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'verbose',
          class: className,
          code: 'V001',
          processId: '54321',
          document: '111222333',
          response: 'Verbose response',
          request: 'Verbose request',
          headers: { 'x-custom': 'custom-value' },
        }),
      );
    });

    it('should log verbose message with default class when not provided', () => {
      const verboseMessage = {
        code: 'V002',
        processId: '99999',
        document: '444555666',
        response: 'Another verbose response',
        request: 'Another verbose request',
        headers: { 'x-tracking': 'tracking-value' },
      };

      logger.verbose!(verboseMessage);

      expect(verboseSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'verbose',
          class: 'Unknown',
          code: 'V002',
          processId: '99999',
          document: '444555666',
          response: 'Another verbose response',
          request: 'Another verbose request',
          headers: { 'x-tracking': 'tracking-value' },
        }),
      );
    });

    it('should handle verbose message with missing properties', () => {
      const verboseMessage = {
        code: 'V003',
        processId: '77777',
      };

      logger.verbose!(verboseMessage, 'TestVerboseClass');

      expect(verboseSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'verbose',
          class: 'TestVerboseClass',
          code: 'V003',
          processId: '77777',
          document: undefined,
          response: undefined,
          request: undefined,
          headers: undefined,
        }),
      );
    });
  });

  describe('JSON formatting', () => {
    it('should properly format complex objects', () => {
      const complexMessage = {
        code: 'COMPLEX',
        processId: '12345',
        document: '987654321',
        response: { status: 'error', details: { reason: 'timeout' } },
        request: { method: 'POST', body: { data: 'test' } },
        headers: { 'content-type': 'application/json', 'authorization': 'Bearer token' },
      };

      logger.error(complexMessage, 'extra', 'ComplexClass');

      expect(consoleSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'error',
          class: 'ComplexClass',
          code: 'COMPLEX',
          processId: '12345',
          document: '987654321',
          response: { status: 'error', details: { reason: 'timeout' } },
          request: { method: 'POST', body: { data: 'test' } },
          headers: { 'content-type': 'application/json', 'authorization': 'Bearer token' },
        }),
      );
    });

    it('should handle null and undefined values', () => {
      const messageWithNulls = {
        code: null,
        processId: undefined,
        document: '123456789',
        response: null,
        request: undefined,
        headers: { 'content-type': 'application/json' },
      };

      logger.error(messageWithNulls, 'extra', 'NullTestClass');

      expect(consoleSpy).toHaveBeenCalledWith(
        JSON.stringify({
          level: 'error',
          class: 'NullTestClass',
          code: null,
          processId: undefined,
          document: '123456789',
          response: null,
          request: undefined,
          headers: { 'content-type': 'application/json' },
        }),
      );
    });
  });

  describe('Message types (object vs string)', () => {
    it('should handle object message in log', () => {
      const consoleSpyLog = jest.spyOn(console, 'log').mockImplementation();
      logger.log({ detail: 'object test' });
      expect(consoleSpyLog).toHaveBeenCalledWith(expect.stringContaining('"detail":"object test"'));
      consoleSpyLog.mockRestore();
    });

    it('should handle object message in fatal', () => {
      const consoleSpyError = jest.spyOn(console, 'error').mockImplementation();
      logger.fatal({ detail: 'fatal object' });
      expect(consoleSpyError).toHaveBeenCalledWith(expect.stringContaining('"detail":"fatal object"'));
      consoleSpyError.mockRestore();
    });

    it('should handle string message in error', () => {
      const consoleSpyError = jest.spyOn(console, 'error').mockImplementation();
      logger.error('error string');
      expect(consoleSpyError).toHaveBeenCalledWith(expect.stringContaining('"message":"error string"'));
      consoleSpyError.mockRestore();
    });

    it('should handle object message in warn', () => {
      const consoleSpyWarn = jest.spyOn(console, 'warn').mockImplementation();
      logger.warn({ detail: 'warn object' });
      expect(consoleSpyWarn).toHaveBeenCalledWith(expect.stringContaining('"detail":"warn object"'));
      consoleSpyWarn.mockRestore();
    });

    it('should handle object message in debug', () => {
      const consoleSpyDebug = jest.spyOn(console, 'debug').mockImplementation();
      logger.debug({ detail: 'debug object' });
      expect(consoleSpyDebug).toHaveBeenCalledWith(expect.stringContaining('"detail":"debug object"'));
      consoleSpyDebug.mockRestore();
    });

    it('should handle string message in verbose', () => {
      const consoleSpyDebug = jest.spyOn(console, 'debug').mockImplementation();
      logger.verbose('verbose string');
      expect(consoleSpyDebug).toHaveBeenCalledWith(expect.stringContaining('"message":"verbose string"'));
      consoleSpyDebug.mockRestore();
    });
  });

  describe('Internal logs filtering', () => {
    it('should not log when context is in nestContexts (e.g., NestFactory)', () => {
      const consoleSpyLog = jest.spyOn(console, 'log').mockImplementation();
      logger.log('Internal log message', 'NestFactory');
      expect(consoleSpyLog).not.toHaveBeenCalled();
      consoleSpyLog.mockRestore();
    });

    it('should not log when context is InstanceLoader', () => {
      const consoleSpyLog = jest.spyOn(console, 'log').mockImplementation();
      logger.log('Another internal log', 'InstanceLoader');
      expect(consoleSpyLog).not.toHaveBeenCalled();
      consoleSpyLog.mockRestore();
    });

    it('should filter internal logs in fatal method', () => {
      const consoleSpyError = jest.spyOn(console, 'error').mockImplementation();
      logger.fatal('Fatal message', 'NestFactory');
      expect(consoleSpyError).not.toHaveBeenCalled();
      consoleSpyError.mockRestore();
    });

    it('should filter internal logs in warn method', () => {
      const consoleSpyWarn = jest.spyOn(console, 'warn').mockImplementation();
      logger.warn('Warn message', 'RoutesResolver');
      expect(consoleSpyWarn).not.toHaveBeenCalled();
      consoleSpyWarn.mockRestore();
    });

    it('should filter internal logs in debug method', () => {
      const consoleSpyDebug = jest.spyOn(console, 'debug').mockImplementation();
      logger.debug('Debug message', 'RouterExplorer');
      expect(consoleSpyDebug).not.toHaveBeenCalled();
      consoleSpyDebug.mockRestore();
    });

    it('should filter internal logs in verbose method', () => {
      const consoleSpyDebug = jest.spyOn(console, 'debug').mockImplementation();
      logger.verbose('Verbose message', 'NestApplication');
      expect(consoleSpyDebug).not.toHaveBeenCalled();
      consoleSpyDebug.mockRestore();
    });
  });
});
