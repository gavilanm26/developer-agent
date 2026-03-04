import type { Request } from 'express';

import { ValidateOtcPayloadModel } from '../models/validate-otc-payload.model';
import { ValidateOtcResponseModel } from '../models/validate-otc-response.model';

export abstract class ValidateOtcRepositoryPort {
  abstract validate(
    data: ValidateOtcPayloadModel,
    req: Request,
  ): Promise<ValidateOtcResponseModel>;
}
