import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { Request } from 'express';

import { {{ENDPOINT_PASCAL}}Adapter } from '../../domain/{{ENDPOINT_NAME}}.adapter';
import { {{ENDPOINT_PASCAL}}Request } from '../../domain/interfaces/{{ENDPOINT_NAME}}-request.interface';

@Injectable()
export class Ms{{ENDPOINT_PASCAL}}Adapter implements {{ENDPOINT_PASCAL}}Adapter {
  private readonly logger = new Logger(Ms{{ENDPOINT_PASCAL}}Adapter.name);

  private readonly baseUrl = process.env.{{EXTERNAL_BASE_URL_ENV}} || '';
  private readonly version = '{{EXTERNAL_API_VERSION}}';

  constructor(private readonly http: HttpService) {}

  async {{METHOD_NAME}}(data: {{ENDPOINT_PASCAL}}Request, req: Request): Promise<any> {
    const url = this.baseUrl.concat(this.version, '{{EXTERNAL_PATH}}');

    const headers = {
      'x-tracking-op': String(req.headers['x-tracking-op'] || ''),
    };

    const res = await firstValueFrom(this.http.post(url, data, { headers }));
    return res.data;
  }
}
