import { Test, TestingModule } from '@nestjs/testing';
import { JwtAuthService } from './jwt-auth.service';
import { UnauthorizedException } from '@nestjs/common';
import { AuthRequestDto } from '../domain/request';
import { Validate } from './use-case/validate';
import { TokenService } from '../domain/token.service';
import { ResponseDto } from '../../../dto/response';
import { Request } from 'express';

const mockJwtService = () => ({
  sign: jest.fn(),
});

describe('JwtAuthService', () => {
  let jwtAuthService: JwtAuthService;
  let tokenService: TokenService;
  let validateToken: Validate;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        JwtAuthService,
        {
          provide: Validate,
          useFactory: () => ({
            token: jest.fn(),
          }),
        },
        {
          provide: TokenService,
          useFactory: () => ({
            sign: jest.fn(),
          }),
        },
        {
          provide: TokenService,
          useFactory: mockJwtService,
        },
      ],
    }).compile();

    jwtAuthService = module.get<JwtAuthService>(JwtAuthService);
    validateToken = module.get<Validate>(Validate);
    tokenService = module.get<TokenService>(TokenService);
  });

  it('should be defined', () => {
    expect(jwtAuthService).toBeDefined();
  });

  it('should throw UnauthorizedException when token is not valid', async () => {
    const invalidToken: AuthRequestDto = {
      data: {
        value: 'invalid-token',
        documentNumber: 'customer',
        documentType: 'type',
        password: 'password',
      },
    };

    jest.spyOn(validateToken, 'token').mockReturnValue(false);

    const req: Request = {
      headers: {
        'X-Tracking-Op': '',
      },
      body: '',
    } as any;

    await expect(jwtAuthService.createToken(invalidToken, req)).rejects.toThrow(
      UnauthorizedException,
    );
  });

  it('should sign a token when the provided token is valid', async () => {
    const validToken: AuthRequestDto = {
      data: {
        value: 'invalid-token',
        documentNumber: 'customer',
        documentType: 'type',
        password: 'password',
      },
    };
    const signedToken: ResponseDto = {
      response: 'token',
    };

    jest.spyOn(validateToken, 'token').mockReturnValue(true);
    jest.spyOn(tokenService, 'sign').mockResolvedValue(signedToken);
    const req: Request = {
      headers: {
        'X-Tracking-Op': '',
      },
      body: '',
    } as any;

    const result = await jwtAuthService.createToken(validToken, req);
    expect(tokenService.sign).toHaveBeenCalledWith(validToken, req);
    expect(result).toBe(signedToken);
  });
});
