import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { ResponseDto } from '@app/dto/response';
import { AxiosResponse } from 'axios';
import { httpLogger } from '../../../../../../commons/http-logger/httpLogger';
import { ConfigSiteClientPort } from '../../../../domain/ports/config-site.client.port';

@Injectable()
export class MsIdentityConfigRestClient implements ConfigSiteClientPort {
  private readonly urlIdentityManagement: string;
  private readonly version: string;
  private readonly logger = new Logger(MsIdentityConfigRestClient.name);

  constructor(private readonly httpService: HttpService) {
    this.urlIdentityManagement =
      process.env.APIURLIDENTITYMANAGEMENT ??
      'ERROR APIURLIDENTITYMANAGEMENT NOT FOUND';
    this.version = '/v1';
  }

  async get(payload: any): Promise<ResponseDto> {
    const targetUrl = this.urlIdentityManagement.concat(this.version, '/site');
    const payloadData = payload.data;
    const headers = {
      'X-Tracking-Op': 'site',
    };
    const responseValue = await firstValueFrom<AxiosResponse>(
      this.httpService
        .post(targetUrl, payloadData, { headers })
        .pipe(
          httpLogger(
            this.logger,
            true,
            '',
            payloadData?.documentNumber,
            payload,
            headers,
            targetUrl,
          ),
        ),
    );

    return responseValue.data;
  }
}
