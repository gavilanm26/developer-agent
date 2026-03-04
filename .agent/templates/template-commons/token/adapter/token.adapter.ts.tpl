import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { AxiosResponse } from 'axios';

@Injectable()
export class TokenAdapter {
  private readonly urlToken: string;
  private readonly version: string;
  constructor(private readonly httpService: HttpService) {
    this.urlToken =
      process.env.APIURLCOMMONSIDENTITYMANAGEMENT ??
      'ERROR APIURLCOMMONSIDENTITYMANAGEMENT NOT FOUND';
    this.version = '/v1';
  }
  async get() {
    return await firstValueFrom<AxiosResponse>(
      this.httpService.post(
        this.urlToken.concat(this.version, '/token-core-cache'),
      ),
    );
  }
}
