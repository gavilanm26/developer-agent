import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import { TokenKycService } from './token-kyc-service.service';

describe('TokenKycService', () => {
  let service: TokenKycService;
  let jwtService: JwtService;

  beforeEach(async () => {
    process.env.APPENCRYPTJWT = 'testSecretKey';

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TokenKycService,
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
      ],
    }).compile();

    service = module.get<TokenKycService>(TokenKycService);
    jwtService = module.get<JwtService>(JwtService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should call jwtService.signAsync with an encrypted id', async () => {
    const documentNumber = '1234567890';
    await service.signToken(documentNumber);

    expect(jwtService.signAsync).toHaveBeenCalledWith(
      expect.objectContaining({
        id: expect.any(String),
      }),
    );
  });
});
