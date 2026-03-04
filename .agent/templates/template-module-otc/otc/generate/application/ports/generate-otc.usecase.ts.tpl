import type { Request } from 'express';

import { BasicDataRequestModel } from '../../domain/models/basic-data-request.model';

export abstract class GenerateOtcUseCase {
  abstract generate(body: BasicDataRequestModel, req: Request): Promise<void>;
}
