import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { ResponseDto } from '../../../../dto/response';
import { AxiosResponse } from 'axios';
import { httpLogger } from '../../../../commons/http-logger/httpLogger';
import { ConfigSiteAdapter } from '../../domain/config-site.adapter';

@Injectable()
export class MsIdentityConfigAdapter implements ConfigSiteAdapter {
  private readonly urlIdentityManagement: string;
  private readonly version: string;
  private readonly logger = new Logger(MsIdentityConfigAdapter.name);

  constructor(private readonly httpService: HttpService) {
    this.urlIdentityManagement =
      process.env.APIURLIDENTITYMANAGEMENT ??
      'ERROR APIURLIDENTITYMANAGEMENT NOT FOUND';
    this.version = '/v1';
  }

  async getConfig(payload: any): Promise<ResponseDto> {
    const responseValue = await firstValueFrom<AxiosResponse>(
      this.httpService
        .post(
          this.urlIdentityManagement.concat(this.version, '/site'),
          payload.data,
          {
            headers: {
              'X-Tracking-Op': 'site',
            },
          },
        )
        .pipe(
          httpLogger(
            this.logger,
            true,
            '',
            payload.data?.documentNumber,
            payload,
          ),
        ),
    );

    return responseValue.data;
  }
}
