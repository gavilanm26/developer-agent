import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { AxiosResponse } from 'axios';
import { firstValueFrom } from 'rxjs';
import type { Request } from 'express';

import { httpLogger } from '@commons/http-logger/httpLogger';
import { {{PORT_PASCAL}} } from '../../../../domain/ports/{{EXTERNAL_KEBAB}}.client.port';
import { {{REQUEST_DTO_PASCAL}} } from '{{REQUEST_DTO_IMPORT}}';
import { {{RESPONSE_DTO_PASCAL}} } from '{{RESPONSE_DTO_IMPORT}}';
import { SetDataMapper } from '../mappers/set-data.mapper';

@Injectable()
export class {{EXTERNAL_PASCAL}}RestClient implements {{PORT_PASCAL}} {
  private readonly logger = new Logger({{EXTERNAL_PASCAL}}RestClient.name + ' {{EXTERNAL_KEBAB}}');
  private readonly baseUrl: string;
  private readonly version = '{{API_VERSION}}';

  constructor(
    private readonly httpService: HttpService,
    private readonly set: SetDataMapper,
    // private readonly token: MsTokenAdapter,
  ) {
    this.baseUrl = process.env.{{BASE_URL_ENV}} ?? 'ERROR {{BASE_URL_ENV}} NOT FOUND';
  }

  async {{METHOD_NAME}}(
    input: {{REQUEST_DTO_PASCAL}},
    req: Request,
  ): Promise<{{RESPONSE_DTO_PASCAL}}> {
    const url = this.baseUrl.concat(this.version, this.set.url(input));
    const headers = this.set.headers(
      input,
      String(req.headers['x-tracking-op']),
      req,
    );
    const request = this.set.request(input);

    const response = await firstValueFrom<AxiosResponse<{{RESPONSE_DTO_PASCAL}}>>(
      this.httpService
        .post(url, request, {
          headers,
          validateStatus: (status: number) =>
            (status >= 200 && status < 300) || status === 400,
        })
        .pipe(
          httpLogger(
            this.logger,
            false,
            req.headers['x-tracking-op'],
            (input as any)?.documentNumber,
            request,
            headers,
            url,
          ),
        ),
    );

    return response.data;
  }
}
