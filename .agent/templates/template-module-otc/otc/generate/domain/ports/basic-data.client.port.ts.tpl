import type { Request } from 'express';

import { BasicDataRequestModel } from '../models/basic-data-request.model';
import { BasicDataModel } from '../models/basic-data.model';

export abstract class BasicDataClientPort {
  abstract get(
    body: BasicDataRequestModel,
    req: Request,
  ): Promise<BasicDataModel>;
}
