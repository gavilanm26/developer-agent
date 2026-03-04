import { Injectable, Logger } from '@nestjs/common';
import { GoogleReCaptchaClientPort } from '@modules/re-captcha/domain/ports/google-re-captcha.client.port';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { AxiosResponse } from 'axios';
import { SetDataMapper } from '@modules/re-captcha/infrastructure/adapters/outbound/mappers/set-data.mapper';
import { httpLogger } from '@commons/http-logger/httpLogger';
import { ReCaptchaResponseModel } from '@modules/re-captcha/domain/models/re-captcha-response.model';
import { Request } from 'express';

@Injectable()
export class GoogleReCaptchaRestClient implements GoogleReCaptchaClientPort {
  private readonly url: string;
  private readonly logger = new Logger(
    GoogleReCaptchaRestClient.name + ' re-captcha',
  );

  constructor(
    private readonly httpService: HttpService,
    private readonly set: SetDataMapper,
  ) {
    this.url = process.env.INFRAGOOGLERECAPTCHAURL ?? 'ERROR URL NOT FOUND';
  }

  async verify(token: string, req: Request): Promise<ReCaptchaResponseModel> {
    const targetUrl = this.url.concat(this.set.queryString(token));
    const response = await firstValueFrom<AxiosResponse<ReCaptchaResponseModel>>(
      this.httpService
        .post<ReCaptchaResponseModel>(targetUrl)
        .pipe(
          httpLogger(
            this.logger,
            false,
            req.headers['x-tracking-op'],
            null,
            null,
            null,
            targetUrl,
          ),
        ),
    );
    return response.data;
  }
}
