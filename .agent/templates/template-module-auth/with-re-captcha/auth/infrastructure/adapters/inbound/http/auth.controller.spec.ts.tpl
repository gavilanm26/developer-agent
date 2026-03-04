import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from '@modules/auth/infrastructure/adapters/inbound/http/auth.controller';
import { AuthUsecase } from '@modules/auth/application/ports/auth.usecase';
import { TypeOfDocuments } from '@commons/enums/type-of-documents.enum';
import { AuthHttpDto } from '@modules/auth/infrastructure/adapters/inbound/http/dto/auth.http.dto';
import { ArgumentMetadata, ValidationPipe } from '@nestjs/common';
import { Request } from 'express';

describe('AuthController', () => {
  let authController: AuthController;
  let authService: jest.Mocked<AuthUsecase>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        {
          provide: AuthUsecase,
          useValue: {
            token: jest.fn(),
          },
        },
      ],
    }).compile();

    authController = module.get<AuthController>(AuthController);
    authService = module.get<AuthUsecase>(
      AuthUsecase,
    ) as jest.Mocked<AuthUsecase>;
  });

  it('should be defined', () => {
    expect(authController).toBeDefined();
  });

  describe('token', () => {
    it('should call AuthService.token with the provided body and request', async () => {
      const mockRequest = {
        body: {},
        headers: {},
        query: {},
        params: {},
        method: '',
        url: '',
      } as unknown as Request;

      const mockBody: AuthHttpDto = {
        documentNumber: '123456789',
        documentType: 'CC' as any,
        password: 'securePassword123',
        tokenRecaptcha: 'validToken',
      };

      await authController.token(mockBody, mockRequest);

      expect(authService.token.mock.calls[0]).toEqual([mockBody, mockRequest]);
    });
  });

  describe('ValidationPipe', () => {
    it('should validate the provided DTO using ValidationPipe', async () => {
      const validationPipe = new ValidationPipe();

      const mockDto: AuthHttpDto = {
        documentNumber: '987654321',
        documentType: TypeOfDocuments.CE,
        password: 'securePassword321',
        tokenRecaptcha: 'validTokenCE',
      };

      const mockExecutionContext: ArgumentMetadata = {
        type: 'body',
        metatype: AuthHttpDto,
        data: '',
      };

      const result = (await validationPipe.transform(
        mockDto,
        mockExecutionContext,
      )) as AuthHttpDto;

      expect(result).toEqual(mockDto);
    });
  });
});
