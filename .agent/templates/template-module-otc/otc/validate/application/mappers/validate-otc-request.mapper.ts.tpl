import { Injectable } from '@nestjs/common';

import { ValidateOtcRequestModel } from '../../domain/models/validate-otc-request.model';
import { BasicDataRequestModel } from '../../domain/models/basic-data-request.model';
import { BasicDataModel } from '../../domain/models/basic-data.model';
import { ValidateOtcPayloadModel } from '../../domain/models/validate-otc-payload.model';

@Injectable()
export class ValidateOtcRequestMapper {
  toBasicDataRequest(data: ValidateOtcRequestModel): BasicDataRequestModel {
    return {
      documentType: data.documentType,
      documentNumber: data.documentNumber,
    };
  }

  toRepository(
    data: ValidateOtcRequestModel,
    basicData: BasicDataModel,
  ): ValidateOtcPayloadModel {
    return {
      documentType: data.documentType,
      documentNumber: data.documentNumber,
      code: data.code,
      email: basicData.emailAddr,
      cellPhone: basicData.cellPhone,
    };
  }
}
