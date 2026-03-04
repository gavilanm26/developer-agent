import { Test, TestingModule } from '@nestjs/testing';
import type { Request } from 'express';

import { ValidateOtcUseCase } from '../../../../application/ports/validate-otc.usecase';
import { ValidateOtcController } from './validate-otc.controller';
import { ValidateOtcHttpDto } from './dto/validate-otc.http.dto';
import { TypeOfDocuments } from '@commons/enums/type-of-documents.enum';

describe('ValidateOtcController', () => {
  let controller: ValidateOtcController;
  let validateUseCase: ValidateOtcUseCase;

  beforeEach(async () => {
    const validateServiceMock = {
      validate: jest.fn().mockResolvedValue(undefined),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [ValidateOtcController],
      providers: [
        { provide: ValidateOtcUseCase, useValue: validateServiceMock },
      ],
    }).compile();

    controller = module.get<ValidateOtcController>(ValidateOtcController);
    validateUseCase = module.get<ValidateOtcUseCase>(ValidateOtcUseCase);
  });

  it('should validate OTP', async () => {
    const validateSpy = jest.spyOn(validateUseCase, 'validate');

    const otpDto: ValidateOtcHttpDto = {
      documentNumber: '',
      documentType: TypeOfDocuments.CC,
      code: '',
    };

    const req: Request = {} as any;
    const result = await controller.validateOtc(otpDto, req);

    expect(validateSpy).toHaveBeenCalledWith(otpDto, req);
    expect(result).toBeUndefined();
  });
});
