import { Injectable, Logger } from '@nestjs/common';
import { CoreAuthClientPort } from '@modules/auth/domain/ports/core-auth.client.port';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { AuthRequest } from '@modules/auth/domain/models/auth-request.model';
import { AuthTokenCommonsClient } from '../commons/auth-token-commons.client';
import { SetDataMapper } from '@modules/auth/infrastructure/adapters/outbound/mappers/set-data.mapper';
import { httpLogger } from '@commons/http-logger/httpLogger';
import { AxiosResponse } from 'axios';
import { Request } from 'express';

@Injectable()
export class AuthCoreRestClient implements CoreAuthClientPort {
  private readonly urlAuth: string;
  private readonly logger = new Logger(AuthCoreRestClient.name + ' auth');

  constructor(
    private readonly httpService: HttpService,
    private readonly set: SetDataMapper,
    private readonly tokenCore: AuthTokenCommonsClient,
  ) {
    this.urlAuth = process.env.APIAUTHURL ?? 'ERROR APIAUTHURL NOT FOUND';
  }

  async auth(authRequest: AuthRequest, req: Request): Promise<void> {
    const url = this.urlAuth;
    const requestData = this.set.request(authRequest);
    const headers = this.set.headers(
      authRequest,
      String(req.headers['x-tracking-op']),
      (await this.tokenCore.get()).data,
      req,
    );

    await firstValueFrom<AxiosResponse>(
      this.httpService
        .post(url, requestData, { headers })
        .pipe(
          httpLogger(
            this.logger,
            false,
            req.headers['x-tracking-op'],
            authRequest.documentNumber,
            requestData,
            headers,
            url,
          ),
        ),
    );
  }
}
