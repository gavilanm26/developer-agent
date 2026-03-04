import type { Request } from 'express';

import { GenerateOtcPayloadModel } from '../models/generate-otc-payload.model';
import { GenerateOtcResponseModel } from '../models/generate-otc-response.model';

export abstract class GenerateOtcClientPort {
  abstract generate(
    data: GenerateOtcPayloadModel,
    req: Request,
  ): Promise<GenerateOtcResponseModel>;
}
