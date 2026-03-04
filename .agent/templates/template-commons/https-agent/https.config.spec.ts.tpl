import { httpModuleConfig } from './https.config';
import * as https from 'https';

jest.mock('https', () => ({
  Agent: jest.fn().mockImplementation(() => ({
    rejectUnauthorized: false,
    cert: 'mocked-cert',
    key: 'mocked-key',
    ca: 'mocked-ca',
  })),
}));

describe('httpModuleConfig', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    jest.clearAllMocks();
    process.env = { ...originalEnv };
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  describe('HttpModule configuration', () => {
    it('should export HttpModule configuration', () => {
      expect(httpModuleConfig).toBeDefined();
      expect(httpModuleConfig).toHaveProperty('module');
    });

    it('should be a valid DynamicModule', () => {
      expect(httpModuleConfig).toBeDefined();
      expect(typeof httpModuleConfig.module).toBe('function');
      expect(httpModuleConfig).toHaveProperty('module');
    });

    it('should have correct module structure', () => {
      expect(httpModuleConfig).toMatchObject({
        module: expect.any(Function),
      });
    });

    it('should execute useFactory and create httpsAgent with environment variables', () => {
      process.env.CERTIFICATE = 'certificado_base64';
      process.env.CERTIFICATEKEY = 'llave_base64';
      process.env.CERTIFICATECA = 'ca_base64';

      let useFactory;
      if ((httpModuleConfig as any).providers?.[0]?.useFactory) {
        useFactory = (httpModuleConfig as any).providers[0].useFactory;
      } else if ((httpModuleConfig as any).useFactory) {
        useFactory = (httpModuleConfig as any).useFactory;
      } else {
        expect(httpModuleConfig).toBeDefined();
        expect(https.Agent).toHaveBeenCalled();
        return;
      }

      const config = useFactory();

      expect(config).toBeDefined();
      expect(config.httpsAgent).toBeDefined();
      expect(https.Agent).toHaveBeenCalledWith({
        rejectUnauthorized: false,
        cert: Buffer.from('certificado_base64', 'base64').toString('binary'),
        key: Buffer.from('llave_base64', 'base64').toString('binary'),
        ca: Buffer.from('ca_base64', 'base64').toString('binary'),
      });
    });

    it('should use default error messages when environment variables are missing', () => {
      delete process.env.CERTIFICATE;
      delete process.env.CERTIFICATEKEY;
      delete process.env.CERTIFICATECA;

      let useFactory;
      if ((httpModuleConfig as any).providers?.[0]?.useFactory) {
        useFactory = (httpModuleConfig as any).providers[0].useFactory;
      } else if ((httpModuleConfig as any).useFactory) {
        useFactory = (httpModuleConfig as any).useFactory;
      } else {
        expect(httpModuleConfig).toBeDefined();
        expect(https.Agent).toHaveBeenCalled();
        return;
      }

      const config = useFactory();

      expect(config).toBeDefined();
      expect(config.httpsAgent).toBeDefined();
      expect(https.Agent).toHaveBeenCalledWith({
        rejectUnauthorized: false,
        cert: Buffer.from('ERROR CERTIFICATE NOT FOUND', 'base64').toString(
          'binary',
        ),
        key: Buffer.from('ERROR CERTIFICATEKEY NOT FOUND', 'base64').toString(
          'binary',
        ),
        ca: Buffer.from('ERROR CERTIFICATECA NOT FOUND', 'base64').toString(
          'binary',
        ),
      });
    });

    it('should handle empty string environment variables', () => {
      process.env.CERTIFICATE = '';
      process.env.CERTIFICATEKEY = '';
      process.env.CERTIFICATECA = '';

      let useFactory;
      if ((httpModuleConfig as any).providers?.[0]?.useFactory) {
        useFactory = (httpModuleConfig as any).providers[0].useFactory;
      } else if ((httpModuleConfig as any).useFactory) {
        useFactory = (httpModuleConfig as any).useFactory;
      } else {
        expect(httpModuleConfig).toBeDefined();
        expect(https.Agent).toHaveBeenCalled();
        return;
      }

      const config = useFactory();

      expect(config).toBeDefined();
      expect(config.httpsAgent).toBeDefined();
      expect(https.Agent).toHaveBeenCalledWith({
        rejectUnauthorized: false,
        cert: Buffer.from('', 'base64').toString('binary'),
        key: Buffer.from('', 'base64').toString('binary'),
        ca: Buffer.from('', 'base64').toString('binary'),
      });
    });
  });
});
