import { DeviceData } from '../libs/device/device-data';
import { DateLib } from '../libs/date/date-lib';
import { Request } from 'express';

export class CommonHeaders {
  get(req: Request): Record<string, string> {
    const deviceData = new DeviceData();
    const dateLib = new DateLib();
    const clientIp = (req.headers['x-client-ip'] as string) || 'IP NOT FOUND';
    const custLoginId =
      (req.headers['x-security-custloginid'] as string) || 'HEADER NOT FOUND';
    return {
      'Content-Type': 'application/json',
      'X-Security-CustLoginId': custLoginId,
      'X-Invoker-Country': 'CO',
      'X-Invoker-UserIPAddress': clientIp,
      'X-Invoker-ServerIPAddress': deviceData.getIpAddress(),
      'X-Invoker-UserMACAddress': deviceData.getMACAddress(),
      'X-Invoker-ServerMACAddress': deviceData.getMACAddress(),
      'x-invoker-processdate': dateLib.getCurrentDate(),
      'X-Ident-TransactionDate': new Date().toISOString().split('.')[0],
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
      'X-StartDt': dateLib.getBogotaDateTimeWithMilliseconds(),
    };
  }
}
