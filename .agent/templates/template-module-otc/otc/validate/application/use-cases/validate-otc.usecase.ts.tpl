import { Injectable } from '@nestjs/common';
import type { Request } from 'express';

import { ValidateOtcUseCase } from '../ports/validate-otc.usecase';
import { ValidateOtcRequestModel } from '../../domain/models/validate-otc-request.model';
import { BasicDataClientPort } from '../../domain/ports/basic-data.client.port';
import { ValidateOtcRepositoryPort } from '../../domain/ports/validate-otc.repository.port';
import { OtcStateCachePort } from '../../domain/ports/otc-state.cache.port';
import { ValidateOtcRequestMapper } from '../mappers/validate-otc-request.mapper';

@Injectable()
export class ValidateOtcService implements ValidateOtcUseCase {
  private static readonly SUCCESS_RESPONSE_TYPE = 'OK';

  constructor(
    private readonly basicDataClient: BasicDataClientPort,
    private readonly validateRepository: ValidateOtcRepositoryPort,
    private readonly otcStateCache: OtcStateCachePort,
    private readonly requestMapper: ValidateOtcRequestMapper,
  ) {}

  async validate(body: ValidateOtcRequestModel, req: Request): Promise<void> {
    const basicDataRequest = this.requestMapper.toBasicDataRequest(body);
    const basicData = await this.basicDataClient.get(basicDataRequest, req);
    const repositoryData = this.requestMapper.toRepository(body, basicData);

    const validateResponse = await this.validateRepository.validate(
      repositoryData,
      req,
    );

    if (
      validateResponse?.responseType?.value ===
      ValidateOtcService.SUCCESS_RESPONSE_TYPE
    ) {
      await this.otcStateCache.set(String(req.headers['x-tracking-op']));
    }
  }
}
