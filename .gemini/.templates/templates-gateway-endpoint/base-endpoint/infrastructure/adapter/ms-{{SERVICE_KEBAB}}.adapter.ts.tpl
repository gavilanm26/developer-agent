import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { AxiosResponse } from 'axios';
import { Request } from 'express';

import { ResponseDto } from '../../../../dto/response';
import { RequestDto } from '../../../../dto/request';
import { httpLogger } from '../../../../commons/http-logger/httpLogger';

import { {{SERVICE_PASCAL}}Adapter } from '../../domain/{{SERVICE_KEBAB}}.adapter';

@Injectable()
export class Ms{{SERVICE_PASCAL}}Adapter
  implements {{SERVICE_PASCAL}}Adapter
{
  private readonly baseUrl: string;
  private readonly version: string;
  private readonly logger = new Logger(Ms{{SERVICE_PASCAL}}Adapter.name);

  constructor(private readonly httpService: HttpService) {
    this.baseUrl =
      process.env.APIURL{{SERVICE_ENV}} ??
      'APIURL{{SERVICE_ENV}} NOT FOUND';

    this.version = '/v1';
  }

  async {{METHOD_NAME}}(
    payload: RequestDto,
    req: Request,
  ): Promise<ResponseDto> {
    const response = await firstValueFrom<AxiosResponse>(
      this.httpService
        .post(
          `${this.baseUrl}${this.version}/{{ROUTE_PATH}}`,
          payload.data,
          {
            headers: {
              'x-client-ip': (req as any).clientIp || 'IP not available',
              'x-tracking-op': req.headers['x-tracking-op'],
            },
          },
        )
        .pipe(
          httpLogger(
            this.logger,
            false,
            req.headers['x-tracking-op'],
            payload?.data?.documentNumber,
            payload,
          ),
        ),
    );

    if (response.status === 206) {
      return {
        ...response.data,
        statusCode: 206,
      };
    }

    return response.data;
  }
}