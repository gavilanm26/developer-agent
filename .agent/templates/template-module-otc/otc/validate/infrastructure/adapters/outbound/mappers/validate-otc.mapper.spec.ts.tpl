import { ValidateOtcMapper } from './validate-otc.mapper';
import { DeviceData } from '@commons/libs/device/device-data';

jest.mock('@commons/libs/device/device-data');

describe('ValidateOtcMapper', () => {
  let mapper: ValidateOtcMapper;

  beforeEach(() => {
    DeviceData.prototype.getIpAddress = jest.fn().mockReturnValue('127.0.0.1');
    mapper = new ValidateOtcMapper();
  });

  it('should return the correct body object', () => {
    const body = {
      documentType: '',
      documentNumber: '',
      code: '',
      email: '',
      cellPhone: '',
    };

    const result = mapper.request(body);

    expect(result).toEqual({
      govIssueIdent: {
        govIssueIdentType: '',
        identSerialNum: '',
      },
      otc: {
        idOtc: '0004',
        otcCode: '',
      },
      contactInfo: {
        emailAddr: '',
        phoneNum: {
          phone: '',
        },
      },
    });
  });

  it('should return validate endpoint path', () => {
    expect(mapper.url()).toBe('/validateOTC');
  });
});
