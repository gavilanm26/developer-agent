import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { AxiosResponse } from 'axios';
import { Request } from 'express';
import { {{SERVICE_PASCAL}}ClientPort } from '../../../../domain/ports/{{SERVICE_KEBAB}}.client.port';
import { RequestDto } from '../../../../../../dto/request';
import { ResponseDto } from '../../../../../../dto/response';
import { httpLogger } from '../../../../../../commons/http-logger/httpLogger';

@Injectable()
export class {{SERVICE_PASCAL}}RestClient implements {{SERVICE_PASCAL}}ClientPort {
  private readonly url: string;
  private readonly version: string;
  private readonly logger = new Logger({{SERVICE_PASCAL}}RestClient.name);

  constructor(private readonly httpService: HttpService) {
    this.url =
      process.env.URLDOWNSTREAMMS || // <-- Renombrar a la variable de entorno real
      'ERROR URLDOWNSTREAMMS NOT FOUND';
    this.version = '/v1';
  }

  async execute(payload: RequestDto, req: Request): Promise<ResponseDto> {
    const processId = String(req.headers['x-tracking-op'] || '');
    const documentId = payload.data?.documentNumber || '';
    
    // Cambiar este endpoint dependiendo a qué microservicio llama realmente
    const targetUrl = this.url.concat(this.version, '/{{SERVICE_KEBAB}}/execute'); 

    const response = await firstValueFrom<AxiosResponse>(
      this.httpService
        .post(targetUrl, payload.data, {
          headers: {
            'x-tracking-op': processId,
          },
        })
        .pipe(
          httpLogger(
            this.logger,
            true,
            processId,
            documentId,
            payload,
            null, // Si requieres mapear headers adicionales, agrégalos aquí
            targetUrl
          ),
        ),
    );

    return response.data;
  }
}
