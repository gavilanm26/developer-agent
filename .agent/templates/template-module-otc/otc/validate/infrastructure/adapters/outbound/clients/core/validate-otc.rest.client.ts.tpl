import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import type { AxiosResponse } from 'axios';
import type { Request } from 'express';
import { firstValueFrom } from 'rxjs';

import { httpLogger } from '@commons/http-logger/httpLogger';
import { ValidateOtcRepositoryPort } from '../../../../../domain/ports/validate-otc.repository.port';
import { AuthTokenCoreClient } from '../commons/auth-token-core.client';
import { ValidateOtcMapper } from '../../mappers/validate-otc.mapper';
import { ValidateOtcResponseModel } from '../../../../../domain/models/validate-otc-response.model';
import { ValidateOtcPayloadModel } from '../../../../../domain/models/validate-otc-payload.model';

@Injectable()
export class ValidateOtcRestClient implements ValidateOtcRepositoryPort {
  private readonly logger = new Logger(
    ValidateOtcRestClient.name + ' otc-validate',
  );
  private readonly baseUrl: string;
  private readonly version: string;

  constructor(
    private readonly mapper: ValidateOtcMapper,
    private readonly token: AuthTokenCoreClient,
    private readonly httpService: HttpService,
  ) {
    this.baseUrl =
      process.env.APISECURITYMANAGEMENTURL ??
      'ERROR APISECURITYMANAGEMENTURL NOT FOUND';
    this.version = '/V1';
  }

  async validate(
    data: ValidateOtcPayloadModel,
    req: Request,
  ): Promise<ValidateOtcResponseModel> {
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
      AxiosResponse<ValidateOtcResponseModel>
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
