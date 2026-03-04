import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import type { AxiosResponse } from 'axios';
import type { Request } from 'express';
import { firstValueFrom } from 'rxjs';

import { httpLogger } from '@commons/http-logger/httpLogger';
import { GenerateOtcClientPort } from '../../../../../domain/ports/generate-otc.client.port';
import { AuthTokenCoreClient } from '../commons/auth-token-core.client';
import { GenerateOtcMapper } from '../../mappers/generate-otc.mapper';
import { GenerateOtcResponseModel } from '../../../../../domain/models/generate-otc-response.model';
import { GenerateOtcPayloadModel } from '../../../../../domain/models/generate-otc-payload.model';

@Injectable()
export class GenerateOtcRestClient implements GenerateOtcClientPort {
  private readonly logger = new Logger(
    GenerateOtcRestClient.name + ' otc-generate',
  );
  private readonly baseUrl: string;
  private readonly version: string;

  constructor(
    private readonly mapper: GenerateOtcMapper,
    private readonly token: AuthTokenCoreClient,
    private readonly httpService: HttpService,
  ) {
    this.baseUrl =
      process.env.APISECURITYMANAGEMENTURL ||
      'ERROR APISECURITYMANAGEMENTURL NOT FOUND';
    this.version = '/V1';
  }

  async generate(
    data: GenerateOtcPayloadModel,
    req: Request,
  ): Promise<GenerateOtcResponseModel> {
    const processId = String(req.headers['x-tracking-op']);
    const url = this.baseUrl.concat(this.version, this.mapper.url());
    const request = this.mapper.request(data);
    const headers = this.mapper.headers(
      data,
      processId,
      (await this.token.get()).data,
      req,
    );

    const response = await firstValueFrom<
      AxiosResponse<GenerateOtcResponseModel>
    >(
      this.httpService
        .post(url, request, {
          headers,
        })
        .pipe(
          httpLogger(
            this.logger,
            false,
            processId,
            data.documentNumber,
            request,
            headers,
            url,
          ),
        ),
    );

    return response.data;
  }
}
