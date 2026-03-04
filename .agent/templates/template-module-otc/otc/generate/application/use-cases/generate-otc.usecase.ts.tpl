import { Injectable } from '@nestjs/common';
import type { Request } from 'express';

import { GenerateOtcUseCase } from '../ports/generate-otc.usecase';
import { BasicDataRequestModel } from '../../domain/models/basic-data-request.model';
import { BasicDataClientPort } from '../../domain/ports/basic-data.client.port';
import { GenerateOtcClientPort } from '../../domain/ports/generate-otc.client.port';
import { GenerateOtcRequestMapper } from '../mappers/generate-otc-request.mapper';

@Injectable()
export class GenerateOtcService implements GenerateOtcUseCase {
  constructor(
    private readonly basicDataClient: BasicDataClientPort,
    private readonly generateRepository: GenerateOtcClientPort,
    private readonly requestMapper: GenerateOtcRequestMapper,
  ) {}

  async generate(body: BasicDataRequestModel, req: Request): Promise<void> {
    const basicData = await this.basicDataClient.get(body, req);
    const repositoryData = this.requestMapper.toRepository(body, basicData);

    await this.generateRepository.generate(repositoryData, req);
  }
}
