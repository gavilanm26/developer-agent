import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import { MsIdentityAuth } from '../adapter/ms-identity-auth';
import { HttpException, HttpStatus } from '@nestjs/common';
import { AuthRequestDto } from '../../domain/request';
import { Request } from 'express';
import { TokenGuard } from './token.guard';
import Crypto from '../../../../commons/crypto/crypto';
import jwtConfig from '../../domain/jwt.config';

describe('TokenGuard', () => {
  let tokenGuard: TokenGuard;
  let jwtService: JwtService;
  let msIdentityAuth: MsIdentityAuth;

  beforeEach(async () => {
    process.env.APPENCRYPTJWT = 'testSecretKey';

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TokenGuard,
        {
          provide: JwtService,
          useValue: {
            signAsync: jest
              .fn()
              .mockImplementation((payload) =>
                Promise.resolve(`token_${payload.id}`),
              ),
          },
        },
        {
          provide: MsIdentityAuth,
          useValue: {
            validate: jest.fn(),
          },
        },
      ],
    }).compile();

    tokenGuard = module.get<TokenGuard>(TokenGuard);
    jwtService = module.get<JwtService>(JwtService);
    msIdentityAuth = module.get<MsIdentityAuth>(MsIdentityAuth);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(tokenGuard).toBeDefined();
  });

  it('should return a token when validation is successful', async () => {
    const payload: AuthRequestDto = {
      data: {
        documentNumber: '1234567890',
        value: '',
        documentType: '',
        password: '',
      },
    };
    const req = {} as Request;
    const response = { status: 200 };

    jest.spyOn(msIdentityAuth, 'validate').mockResolvedValue(response as any);
    jest.spyOn(Crypto, 'encrypt').mockReturnValue('encrypted_id');

    const result = await tokenGuard.sign(payload, req);

    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(msIdentityAuth.validate).toHaveBeenCalledWith(payload, req);
    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(Crypto.encrypt).toHaveBeenCalledWith(
      payload.data.documentNumber.toString(),
      process.env.APPENCRYPTJWT,
    );
    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(jwtService.signAsync).toHaveBeenCalledWith(
      {
        id: 'encrypted_id',
      },
      {
        algorithm: jwtConfig.algorithm,
        privateKey: jwtConfig.privateKey,
      },
    );

    expect(result).toHaveProperty('response');
    expect(typeof result.response).toBe('string');
    expect(result.response).toContain('token_');
  });

  it('should throw an exception when validation fails', async () => {
    const payload: AuthRequestDto = {
      data: {
        documentNumber: '1234567890',
        value: '',
        documentType: '',
        password: '',
      },
    };
    const req = {} as Request;
    const response = { status: 400 };

    jest.spyOn(msIdentityAuth, 'validate').mockResolvedValue(response as any);

    await expect(tokenGuard.sign(payload, req)).rejects.toThrow(
      new HttpException('invalid data', HttpStatus.UNPROCESSABLE_ENTITY),
    );
  });
});
