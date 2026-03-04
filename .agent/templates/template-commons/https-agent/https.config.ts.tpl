import { HttpModule } from '@nestjs/axios';
import * as https from 'https';

export const httpModuleConfig = HttpModule.registerAsync({
  useFactory: () => ({
    httpsAgent: new https.Agent({
      rejectUnauthorized: false,
      cert: Buffer.from(
        process.env.CERTIFICATE ?? 'ERROR CERTIFICATE NOT FOUND',
        'base64',
      ).toString('binary'),
      key: Buffer.from(
        process.env.CERTIFICATEKEY ?? 'ERROR CERTIFICATEKEY NOT FOUND',
        'base64',
      ).toString('binary'),
      ca: Buffer.from(
        process.env.CERTIFICATECA ?? 'ERROR CERTIFICATECA NOT FOUND',
        'base64',
      ).toString('binary'),
    }),
  }),
});
