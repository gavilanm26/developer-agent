import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { AuthRequestDto } from '../../../../domain/request';
import { AxiosResponse } from 'axios';
import { httpLogger } from '../../../../../../commons/http-logger/httpLogger';
import { Request } from 'express';

@Injectable()
export class MsIdentityAuthRestClient {
  private readonly urlIdentityManagement: string;
  private readonly version: string;
  private readonly logger = new Logger(MsIdentityAuthRestClient.name);

  constructor(private readonly httpService: HttpService) {
    this.urlIdentityManagement =
      process.env.APIURLIDENTITYMANAGEMENT ||
      'ERROR APIURLIDENTITYMANAGEMENT NOT FOUND';
    this.version = '/v1';
  }

  async validate(payload: AuthRequestDto, req: Request) {
    const trackingId = req.headers['x-tracking-op'];
    const payloadData = payload.data;
    const targetUrl = this.urlIdentityManagement.concat(this.version, '/auth');
    const headers = {
      'x-tracking-op': trackingId,
      'x-client-ip': (req as any).clientIp || 'IP not available',
    };

    return await firstValueFrom<AxiosResponse>(
      this.httpService
        .post(targetUrl, payloadData, { headers })
        .pipe(
          httpLogger(
            this.logger,
            true,
            trackingId,
            payloadData.documentNumber,
            'MsIdentityAuthRestClient',
            headers,
            targetUrl,
          ),
        ),
    );
  }
}
