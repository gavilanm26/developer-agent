import type { Request } from 'express';

import { ValidateOtcRequestModel } from '../../domain/models/validate-otc-request.model';

export abstract class ValidateOtcUseCase {
  abstract validate(body: ValidateOtcRequestModel, req: Request): Promise<void>;
}
