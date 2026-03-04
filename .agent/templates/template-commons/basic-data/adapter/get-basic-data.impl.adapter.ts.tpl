import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { AxiosResponse } from 'axios';
import { Request } from 'express';

import { GenerateOtcRequestDto } from '../interface/generate-otc-request.dto';

@Injectable()
export class GetBasicDataImplAdapter {
  private readonly url: string;
  private readonly version: string;

  constructor(private readonly httpService: HttpService) {
    this.url =
      process.env.APIURLCOMMONSBASICDATA ??
      'ERROR APIURLCOMMONSBASICDATA NOT FOUND';
    this.version = '/v1';
  }

  async get(body: GenerateOtcRequestDto, req: Request): Promise<AxiosResponse> {
    return await firstValueFrom<AxiosResponse>(
      this.httpService.post(
        this.url.concat(this.version, '/basic-data'),
        body,
        {
          headers: {
            'x-tracking-op': String(req.headers['x-tracking-op'] ?? ''),
          },
        },
      ),
    );
  }
}
