import { Test, TestingModule } from '@nestjs/testing';
import type { Request } from 'express';

import { GenerateOtcController } from './generate-otc.controller';
import { GenerateOtcUseCase } from '../../../../application/ports/generate-otc.usecase';
import { GenerateOtcHttpDto } from './dto/generate-otc.http.dto';
import { TypeOfDocuments } from '@commons/enums/type-of-documents.enum';

describe('GenerateOtcController', () => {
  let controller: GenerateOtcController;
  let useCase: GenerateOtcUseCase;

  beforeEach(async () => {
    const useCaseMock = {
      generate: jest.fn().mockResolvedValue(undefined),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [GenerateOtcController],
      providers: [{ provide: GenerateOtcUseCase, useValue: useCaseMock }],
    }).compile();

    controller = module.get<GenerateOtcController>(GenerateOtcController);
    useCase = module.get<GenerateOtcUseCase>(GenerateOtcUseCase);
  });

  it('should validate answer', async () => {
    const generateSpy = jest.spyOn(useCase, 'generate');

    const dto: GenerateOtcHttpDto = {
      documentType: TypeOfDocuments.CC,
      documentNumber: '123456789',
      transactionName: 'Aprobación prestamo digital',
    };

    const req: Request = {} as any;
    const result = await controller.generate(dto, req);

    expect(generateSpy).toHaveBeenCalledWith(dto, req);
    expect(result).toBeUndefined();
  });
});
