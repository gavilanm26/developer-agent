import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller';
import { AuthUsecase } from '../../../../application/ports/auth.usecase';
import { ResponseDto } from '@app/dto/response';
import { AuthRequestDto } from '../../../../domain/request';
import { Request } from 'express';
import { ValuesDto } from '../../../../domain/request/values.dto';
import { AuthGuard } from '@nestjs/passport';

describe('AuthController', () => {
  let authController: AuthController;
  let authService: AuthUsecase;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        {
          provide: AuthUsecase,
          useValue: {
            createToken: jest.fn(),
          },
        },
      ],
    })
      .overrideGuard(AuthGuard())
      .useValue({ canActivate: () => true })
      .compile();

    authController = module.get<AuthController>(AuthController);
    authService = module.get<AuthUsecase>(AuthUsecase);
  });

  it('should be defined', () => {
    expect(authController).toBeDefined();
  });

  it('should call AuthUsecase.createToken with the correct parameter and return an access token', async () => {
    const data: ValuesDto = {
      value: 'test-value',
      documentType: 'CC',
      documentNumber: 'ss',
      password: 'aa',
    };
    const testToken: AuthRequestDto = { data };
    const testAccessToken: ResponseDto = {
      response: 'test-access-token',
    };

    jest.spyOn(authService, 'createToken').mockResolvedValue(testAccessToken);

    const req: Request = {
      headers: {
        'X-Tracking-Op': '',
      },
      body: '',
    } as any;
    const result = await authController.createToken(testToken, req);

    expect(authService.createToken).toHaveBeenCalledWith(testToken, req);
    expect(result).toEqual(testAccessToken);
  });
});
