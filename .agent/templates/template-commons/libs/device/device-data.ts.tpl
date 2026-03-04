import * as os from 'os';

export class DeviceData {
  getInterfaces(getDetail) {
    const interfaces = os.networkInterfaces();
    for (const interfaceOS in interfaces) {
      const currentInterfaceOS = interfaces[interfaceOS];

      if (!currentInterfaceOS) continue;

      for (const detailInterfaz of currentInterfaceOS) {
        if (
          getDetail === 'ip' &&
          detailInterfaz.family === 'IPv4' &&
          !detailInterfaz.internal
        ) {
          return detailInterfaz.address;
        }
        if (
          getDetail === 'MAC' &&
          detailInterfaz.mac &&
          detailInterfaz.mac !== '00:00:00:00:00:00'
        ) {
          return detailInterfaz.mac;
        }
      }
    }
  }

  getIpAddress() {
    return this.getInterfaces('ip') ?? '';
  }

  getMACAddress() {
    return this.getInterfaces('MAC') ?? '';
  }
}
