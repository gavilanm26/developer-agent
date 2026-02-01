import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { AuthRequestDto } from '../../domain/request';
import { AxiosResponse } from 'axios';
import { httpLogger } from '../../../../commons/http-logger/httpLogger';
import { Request } from 'express';

@Injectable()
export class MsIdentityAuth {
  private readonly urlIdentityManagement: string;
  private readonly version: string;
  private readonly logger = new Logger(MsIdentityAuth.name);

  constructor(private readonly httpService: HttpService) {
    this.urlIdentityManagement =
      process.env.APIURLIDENTITYMANAGEMENT ||
      'ERROR APIURLIDENTITYMANAGEMENT NOT FOUND';
    this.version = '/v1';
  }

  async validate(payload: AuthRequestDto, req: Request) {
    return await firstValueFrom<AxiosResponse>(
      this.httpService
        .post(
          this.urlIdentityManagement.concat(this.version, '/auth'),
          payload.data,
          {
            headers: {
              'x-tracking-op': req.headers['x-tracking-op'],
              'x-client-ip': (req as any).clientIp || 'IP not available',
            },
          },
        )
        .pipe(
          httpLogger(
            this.logger,
            true,
            req.headers['x-tracking-op'],
            payload.data.documentNumber,
            'MsIdentityAuth',
            req.headers,
          ),
        ),
    );
  }
}
