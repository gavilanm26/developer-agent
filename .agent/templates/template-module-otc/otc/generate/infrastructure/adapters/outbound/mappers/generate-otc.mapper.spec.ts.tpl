import { GenerateOtcMapper } from './generate-otc.mapper';
import { DeviceData } from '@commons/libs/device/device-data';
import { CommonHeaders } from '@commons/headers/common-headers';

jest.mock('@commons/libs/device/device-data');

describe('GenerateOtcMapper', () => {
  let mapper: GenerateOtcMapper;

  beforeEach(() => {
    DeviceData.prototype.getIpAddress = jest.fn().mockReturnValue('127.0.0.1');
    mapper = new GenerateOtcMapper();
  });

  describe('request', () => {
    it('should return the correct body object', () => {
      const body = {
        documentType: '',
        documentNumber: '',
        transactionName: 'Apertura RentaFácil Digital',
        email: '',
        cellPhone: '',
      };

      const result = mapper.request(body);

      expect(result).toMatchObject({
        govIssueIdent: {
          govIssueIdentType: '',
          identSerialNum: '',
        },
        otc: {
          idOtc: '0001',
          otcReason: {
            listParams: [
              {
                value: 'Apertura RentaFácil Digital',
              },
            ],
          },
        },
        otcIssue: {
          listParams: [
            {
              value: 'Código de seguridad',
            },
          ],
        },
        contactInfo: {
          emailAddr: '',
          phoneNum: {
            phone: '',
          },
        },
      });
    });
  });

  describe('url', () => {
    it('should return generate endpoint path', () => {
      expect(mapper.url()).toBe('/generateOTC');
    });
  });

  describe('headers', () => {
    it('should return the correct headers object', () => {
      const data = {
        documentType: 'CC',
        documentNumber: '123456789',
      };
      const processId = 'process123';
      const tokenCore = {
        access_token: 'token123',
      };

      process.env.APISECURITYMANAGEMENTCLIENTID = 'clientId123';
      process.env.APISECURITYMANAGEMENTSECRET = 'clientSecret123';

      const req = { headers: {} } as any;
      const commonHeaders = new CommonHeaders().get(req);

      const result = mapper.headers(data, processId, tokenCore, req);

      expect(result).toEqual(
        expect.objectContaining({
          'X-Invoker-ProcessId': processId,
          'X-Invoker-TxId': processId,
          'X-Invoker-User': data.documentType + data.documentNumber,
          'X-Invoker-RequestNumber': `1-${data.documentType}${data.documentNumber}`,
          'X-Invoker-TerminalId': '',
          client_id: 'clientId123',
          client_secret: 'clientSecret123',
          authorization: `Bearer ${tokenCore.access_token}`,
        })
      );
      expect(result['X-StartDt']).toBeDefined();
    });
  });
});
