import { Test, TestingModule } from '@nestjs/testing';
import type { Request } from 'express';

import { ValidateOtcService } from './validate-otc.usecase';
import { ValidateOtcUseCase } from '../ports/validate-otc.usecase';
import { BasicDataClientPort } from '../../domain/ports/basic-data.client.port';
import { ValidateOtcRepositoryPort } from '../../domain/ports/validate-otc.repository.port';
import { OtcStateCachePort } from '../../domain/ports/otc-state.cache.port';
import { ValidateOtcRequestMapper } from '../mappers/validate-otc-request.mapper';
import { ValidateOtcRequestModel } from '../../domain/models/validate-otc-request.model';

describe('ValidateOtcService', () => {
  let service: ValidateOtcUseCase;
  let basicDataService: BasicDataClientPort;
  let validateRepository: ValidateOtcRepositoryPort;
  let stateCache: OtcStateCachePort;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ValidateOtcService,
        {
          provide: BasicDataClientPort,
          useValue: {
            get: jest.fn(),
          },
        },
        {
          provide: ValidateOtcRepositoryPort,
          useValue: {
            validate: jest.fn(),
          },
        },
        {
          provide: OtcStateCachePort,
          useValue: {
            set: jest.fn(),
          },
        },
        {
          provide: ValidateOtcRequestMapper,
          useValue: {
            toBasicDataRequest: jest.fn((data) => ({
              documentType: data.documentType,
              documentNumber: data.documentNumber,
            })),
            toRepository: jest.fn((data, basicData) => ({
              documentType: data.documentType,
              documentNumber: data.documentNumber,
              code: data.code,
              email: basicData.emailAddr,
              cellPhone: basicData.cellPhone,
            })),
          },
        },
      ],
    }).compile();

    service = module.get<ValidateOtcService>(ValidateOtcService);
    basicDataService = module.get<BasicDataClientPort>(BasicDataClientPort);
    validateRepository = module.get<ValidateOtcRepositoryPort>(
      ValidateOtcRepositoryPort,
    );
    stateCache = module.get<OtcStateCachePort>(OtcStateCachePort);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should validate data and optionally set state', async () => {
    const validateRequest: ValidateOtcRequestModel = {
      code: '',
      documentNumber: '',
      documentType: 'CC',
    };
    const req: Request = {
      headers: {
        'x-tracking-op': 'trackingId',
      },
    } as any;

    const basicDataResponse = {
      emailAddr: 'test@example.com',
      cellPhone: '1234567890',
    };

    const validateResponse = {
      responseType: {
        value: 'OK',
      },
      responseDetail: {
        errorCode: 'OK',
        errorDesc: 'Transacción Exitosa',
        errorType: 'BDA',
      },
    };

    jest.spyOn(basicDataService, 'get').mockResolvedValue(basicDataResponse);
    jest
      .spyOn(validateRepository, 'validate')
      .mockResolvedValue(validateResponse);

    await service.validate(validateRequest, req);

    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(basicDataService.get).toHaveBeenCalledWith(
      {
        documentType: validateRequest.documentType,
        documentNumber: validateRequest.documentNumber,
      },
      req,
    );
    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(validateRepository.validate).toHaveBeenCalledWith(
      {
        documentType: validateRequest.documentType,
        documentNumber: validateRequest.documentNumber,
        code: validateRequest.code,
        email: basicDataResponse.emailAddr,
        cellPhone: basicDataResponse.cellPhone,
      },
      req,
    );
    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(stateCache.set).toHaveBeenCalledWith(req.headers['x-tracking-op']);
  });

  it('should not set state if response type is not OK', async () => {
    const basicDataResponseNotOk = {
      emailAddr: '',
      cellPhone: '',
    };

    jest
      .spyOn(basicDataService, 'get')
      .mockResolvedValue(basicDataResponseNotOk);

    const validateResponseNotOk = {
      responseType: {
        value: 'ERROR',
      },
      responseDetail: {
        errorCode: 'ERROR',
        errorDesc: 'Fallida',
        errorType: 'BDA',
      },
    };

    jest
      .spyOn(validateRepository, 'validate')
      .mockResolvedValue(validateResponseNotOk);

    const validateRequest: ValidateOtcRequestModel = {
      code: '',
      documentNumber: '',
      documentType: 'CC',
    };
    const req: Request = {
      headers: {
        'x-tracking-op': 'trackingId',
      },
    } as any;

    await service.validate(validateRequest, req);

    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(basicDataService.get).toHaveBeenCalledWith(
      {
        documentType: validateRequest.documentType,
        documentNumber: validateRequest.documentNumber,
      },
      req,
    );
    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(stateCache.set).not.toHaveBeenCalled();
  });
});
