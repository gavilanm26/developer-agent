import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { Request } from 'express';

import { {{SERVICE_PASCAL}}Adapter } from '../../domain/{{SERVICE_KEBAB}}.adapter';
import { ResponseDto } from '../../../dto/response';
import { RequestDto } from '../../../dto/request';

@Injectable()
export class Ms{{SERVICE_PASCAL}}Adapter
  implements {{SERVICE_PASCAL}}Adapter
{
  private readonly logger = new Logger(Ms{{SERVICE_PASCAL}}Adapter.name);

  constructor(private readonly http: HttpService) {}

  async {{METHOD_NAME}}(
    data: RequestDto,
    req: Request,
  ): Promise<ResponseDto> {
    try {
      const response = await firstValueFrom(
        this.http.post(
          process.env.MS_URL,
          data,
          { headers: req.headers },
        ),
      );

      return response.data;
    } catch (error) {
      this.logger.error(error);
      throw error;
    }
  }
}
