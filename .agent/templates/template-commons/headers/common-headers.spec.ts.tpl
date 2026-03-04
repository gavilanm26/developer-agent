import { Test } from '@nestjs/testing';
import { CommonHeaders } from './common-headers';
import { DeviceData } from '../libs/device/device-data';
import { DateLib } from '../libs/date/date-lib';
import { Request } from 'express';

jest.mock('../libs/device/device-data');
jest.mock('../libs/date/date-lib');

describe('CommonHeaders', () => {
  let commonHeaders: CommonHeaders;
  let mockDeviceData: any;
  let mockDateLib: any;

  beforeEach(async () => {
    mockDeviceData = {
      getIpAddress: jest.fn().mockReturnValue('127.0.0.1'),
      getMACAddress: jest.fn().mockReturnValue('00:00:00:00:00:00'),
    };

    mockDateLib = {
      getCurrentDate: jest.fn().mockReturnValue('2023-06-30'),
      getBogotaDateTimeWithMilliseconds: jest
        .fn()
        .mockReturnValue('2023-06-30T12:00:00.000'),
    };

    (DeviceData as jest.Mock).mockImplementation(() => mockDeviceData);
    (DateLib as jest.Mock).mockImplementation(() => mockDateLib);

    const moduleRef = await Test.createTestingModule({
      providers: [CommonHeaders],
    }).compile();

    commonHeaders = moduleRef.get<CommonHeaders>(CommonHeaders);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('get()', () => {
    it('should return the correctly formatted headers', () => {
      const mockRequest = {
        headers: {
          'x-client-ip': '192.168.10.20',
          'x-security-custloginid': 'USER_ABC',
        },
      } as unknown as Request;

      const result = commonHeaders.get(mockRequest);

      expect(result).toMatchObject({
        'Content-Type': 'application/json',
        'X-Security-CustLoginId': 'USER_ABC',
        'X-Invoker-Country': 'CO',
        'X-Invoker-UserIPAddress': '192.168.10.20',
        'X-Invoker-ServerIPAddress': '127.0.0.1',
        'X-Invoker-UserMACAddress': '00:00:00:00:00:00',
        'X-Invoker-ServerMACAddress': '00:00:00:00:00:00',
        'x-invoker-processdate': '2023-06-30',
        'X-Invoker-Channel': '07',
        'X-Invoker-ATMId': '0106',
        'X-Invoker-Component': 'apis',
        'x-invoker-branchid': '0166',
        'X-Invoker-SessionKey': 'SESSIONKEYOFI',
        'x-invoker-source': '32',
        'X-Invoker-Network': '0032',
        'X-Invoker-subChannel': '10',
        'X-Invoker-Ally': 'appcredito_qa',
        Accept: 'application/json',
        'X-StartDt': '2023-06-30T12:00:00.000',
      });

      expect(result['X-Ident-TransactionDate']).toMatch(
        /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$/,
      );

      expect(mockDeviceData.getIpAddress).toHaveBeenCalledTimes(1);
      expect(mockDeviceData.getMACAddress).toHaveBeenCalledTimes(2);
      expect(mockDateLib.getCurrentDate).toHaveBeenCalled();
      expect(mockDateLib.getBogotaDateTimeWithMilliseconds).toHaveBeenCalled();
    });

    it('should throw an error if DeviceData fails', () => {
      (DeviceData as jest.Mock).mockImplementation(() => {
        throw new Error('Device error');
      });

      const mockRequest = { headers: {} } as unknown as Request;

      expect(() => new CommonHeaders().get(mockRequest)).toThrow(
        'Device error',
      );
    });

    it('should throw an error if DateLib fails', () => {
      (DateLib as jest.Mock).mockImplementation(() => {
        throw new Error('Date error');
      });

      const mockRequest = { headers: {} } as unknown as Request;

      expect(() => new CommonHeaders().get(mockRequest)).toThrow('Date error');
    });

    it('should use default IP when x-client-ip header is not present', () => {
      const mockRequest = {
        headers: {},
      } as unknown as Request;

      const result = commonHeaders.get(mockRequest);

      expect(result['X-Invoker-UserIPAddress']).toBe('IP NOT FOUND');
    });

    it('should use default IP when x-client-ip header is null', () => {
      const mockRequest = {
        headers: {
          'x-client-ip': null,
        },
      } as unknown as Request;

      const result = commonHeaders.get(mockRequest);

      expect(result['X-Invoker-UserIPAddress']).toBe('IP NOT FOUND');
    });

    it('should use default IP when x-client-ip header is undefined', () => {
      const mockRequest = {
        headers: {
          'x-client-ip': undefined,
        },
      } as unknown as Request;

      const result = commonHeaders.get(mockRequest);

      expect(result['X-Invoker-UserIPAddress']).toBe('IP NOT FOUND');
    });
  });
});
