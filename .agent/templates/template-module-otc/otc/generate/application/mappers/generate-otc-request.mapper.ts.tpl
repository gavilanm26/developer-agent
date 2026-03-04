import { Injectable } from '@nestjs/common';

import { BasicDataRequestModel } from '../../domain/models/basic-data-request.model';
import { BasicDataModel } from '../../domain/models/basic-data.model';
import { GenerateOtcPayloadModel } from '../../domain/models/generate-otc-payload.model';

@Injectable()
export class GenerateOtcRequestMapper {
  toRepository(
    data: BasicDataRequestModel,
    basicData: BasicDataModel,
  ): GenerateOtcPayloadModel {
    return {
      documentType: data.documentType,
      documentNumber: data.documentNumber,
      transactionName: data.transactionName,
      email: basicData.emailAddr,
      cellPhone: basicData.cellPhone,
    };
  }
}
