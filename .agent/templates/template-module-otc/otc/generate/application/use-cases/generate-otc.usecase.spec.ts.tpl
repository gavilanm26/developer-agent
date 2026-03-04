import { Test, TestingModule } from '@nestjs/testing';
import type { Request } from 'express';

import { GenerateOtcService } from './generate-otc.usecase';
import { GenerateOtcUseCase } from '../ports/generate-otc.usecase';
import { BasicDataClientPort } from '../../domain/ports/basic-data.client.port';
import { GenerateOtcClientPort } from '../../domain/ports/generate-otc.client.port';
import { GenerateOtcRequestMapper } from '../mappers/generate-otc-request.mapper';
import { BasicDataRequestModel } from '../../domain/models/basic-data-request.model';

describe('GenerateOtcService', () => {
  let service: GenerateOtcUseCase;
  let basicDataService: BasicDataClientPort;
  let generateRepository: GenerateOtcClientPort;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        GenerateOtcService,
        {
          provide: BasicDataClientPort,
          useValue: {
            get: jest.fn(),
          },
        },
        {
          provide: GenerateOtcClientPort,
          useValue: {
            generate: jest.fn(),
          },
        },
        {
          provide: GenerateOtcRequestMapper,
          useValue: {
            toRepository: jest.fn((data, basicData) => ({
              documentType: data.documentType,
              documentNumber: data.documentNumber,
              transactionName: data.transactionName,
              email: basicData.emailAddr,
              cellPhone: basicData.cellPhone,
            })),
          },
        },
      ],
    }).compile();

    service = module.get<GenerateOtcService>(GenerateOtcService);
    basicDataService = module.get<BasicDataClientPort>(BasicDataClientPort);
    generateRepository = module.get<GenerateOtcClientPort>(
      GenerateOtcClientPort,
    );
  });

  it('debe estar definido', () => {
    expect(service).toBeDefined();
  });

  it('debe llamar a basicData.get y generateRepository.generate con los parámetros correctos', async () => {
    const generateRequest: BasicDataRequestModel = {
      documentNumber: '1007406331',
      documentType: 'CC',
      transactionName: 'Test Transaction',
    };

    const req: Request = {} as Request;

    const basicDataResponse = {
      emailAddr: 'test@example.com',
      cellPhone: '1234567890',
    };

    jest.spyOn(basicDataService, 'get').mockResolvedValue(basicDataResponse);
    jest
      .spyOn(generateRepository, 'generate')
      .mockResolvedValue(Promise.resolve(undefined as never));

    const result = await service.generate(generateRequest, req);

    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(basicDataService.get).toHaveBeenCalledWith(generateRequest, req);
    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(generateRepository.generate).toHaveBeenCalledWith(
      {
        documentType: generateRequest.documentType,
        documentNumber: generateRequest.documentNumber,
        transactionName: generateRequest.transactionName,
        email: basicDataResponse.emailAddr,
        cellPhone: basicDataResponse.cellPhone,
      },
      req,
    );
    expect(result).toBeUndefined();
  });

  it('debe manejar errores cuando basicData.get lanza una excepción', async () => {
    const generateRequest: BasicDataRequestModel = {
      documentNumber: '1007406331',
      documentType: 'CC',
      transactionName: 'Test Transaction',
    };

    const req: Request = {} as Request;

    jest
      .spyOn(basicDataService, 'get')
      .mockRejectedValue(new Error('Error en BasicDataAdapter'));

    await expect(service.generate(generateRequest, req)).rejects.toThrow(
      'Error en BasicDataAdapter',
    );
  });
});
