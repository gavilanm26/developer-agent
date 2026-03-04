import { Injectable } from '@nestjs/common';
import type { Request } from 'express';

import { GetBasicDataImplAdapter } from '@commons/basic-data/adapter/get-basic-data.impl.adapter';
import { BasicDataClientPort } from '../../../../../domain/ports/basic-data.client.port';
import { BasicDataRequestModel } from '../../../../../domain/models/basic-data-request.model';
import { BasicDataModel } from '../../../../../domain/models/basic-data.model';

@Injectable()
export class GetBasicDataClient implements BasicDataClientPort {
  constructor(private readonly basicData: GetBasicDataImplAdapter) {}

  async get(
    body: BasicDataRequestModel,
    req: Request,
  ): Promise<BasicDataModel> {
    const response = await this.basicData.get(body, req);

    return {
      emailAddr: response.data?.emailAddr,
      cellPhone: response.data?.cellPhone,
    };
  }
}
