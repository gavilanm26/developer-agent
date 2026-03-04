import * as os from 'os';
import { DeviceData } from './device-data';

jest.mock('os', () => ({
  ...jest.requireActual('os'),
  networkInterfaces: jest.fn(),
}));

describe('DeviceData', () => {
  let deviceData: DeviceData;

  beforeEach(() => {
    deviceData = new DeviceData();
    jest.restoreAllMocks();
  });

  describe('getInterfaces', () => {
    it('should return the first valid IPv4 address when getDetail is "ip"', () => {
      const mockInterfaces = {
        eth0: [
          { family: 'IPv6', address: '::1', internal: true },
          { family: 'IPv4', address: '192.168.1.100', internal: false },
        ],
        lo: [{ family: 'IPv4', address: '127.0.0.1', internal: true }],
      };

      (os.networkInterfaces as jest.Mock).mockReturnValue(mockInterfaces as any);

      const result = deviceData.getInterfaces('ip');
      expect(result).toBe('192.168.1.100');
    });

    it('should return the first valid MAC address when getDetail is "MAC"', () => {
      const mockInterfaces = {
        eth0: [{ mac: '00:00:00:00:00:00' }, { mac: 'AA:BB:CC:DD:EE:FF' }],
        lo: [{ mac: '00:00:00:00:00:00' }],
      };

      (os.networkInterfaces as jest.Mock).mockReturnValue(mockInterfaces as any);

      const result = deviceData.getInterfaces('MAC');
      expect(result).toBe('AA:BB:CC:DD:EE:FF');
    });

    it('should return undefined if no valid IPv4 address is found', () => {
      const mockInterfaces = {
        lo: [
          { family: 'IPv4', address: '127.0.0.1', internal: true },
          { family: 'IPv6', address: '::1', internal: true },
        ],
      };

      (os.networkInterfaces as jest.Mock).mockReturnValue(mockInterfaces as any);

      const result = deviceData.getInterfaces('ip');
      expect(result).toBeUndefined();
    });

    it('should return undefined if no valid MAC address is found', () => {
      const mockInterfaces = {
        eth0: [{ mac: '00:00:00:00:00:00' }],
        lo: [{ mac: '00:00:00:00:00:00' }],
      };

      (os.networkInterfaces as jest.Mock).mockReturnValue(mockInterfaces as any);

      const result = deviceData.getInterfaces('MAC');
      expect(result).toBeUndefined();
    });

    it('should ignore interfaces that are undefined', () => {
      const mockInterfaces = {
        eth0: undefined,
        lo: [{ family: 'IPv4', address: '127.0.0.1', internal: true }],
      };

      jest
        .spyOn(os, 'networkInterfaces')
        .mockReturnValue(mockInterfaces as any);

      const result = deviceData.getInterfaces('ip');
      expect(result).toBeUndefined();
    });
  });

  describe('getIpAddress', () => {
    it('should return the value from getInterfaces if present', () => {
      jest.spyOn(deviceData, 'getInterfaces').mockReturnValue('192.168.1.10');
      const result = deviceData.getIpAddress();
      expect(result).toBe('192.168.1.10');
    });

    it('should return the empty string if getInterfaces returns undefined', () => {
      jest.spyOn(deviceData, 'getInterfaces').mockReturnValue(undefined);
      const result = deviceData.getIpAddress();
      expect(result).toBe('');
    });
  });

  describe('getMACAddress', () => {
    it('should return the value from getInterfaces if present', () => {
      jest
        .spyOn(deviceData, 'getInterfaces')
        .mockReturnValue('AA-BB-CC-DD-EE-FF');
      const result = deviceData.getMACAddress();
      expect(result).toBe('AA-BB-CC-DD-EE-FF');
    });

    it('should return the empty string if getInterfaces returns undefined', () => {
      jest.spyOn(deviceData, 'getInterfaces').mockReturnValue(undefined);
      const result = deviceData.getMACAddress();
      expect(result).toBe('');
    });
  });
});
