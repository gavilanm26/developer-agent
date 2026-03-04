import { Test, TestingModule } from '@nestjs/testing';
import { HttpException } from '@nestjs/common';
import { GoogleReCaptchaClientPort } from '@modules/re-captcha/domain/ports/google-re-captcha.client.port';
import { VerifyReCaptchaUseCase } from './verify-re-captcha.usecase';

describe('VerifyReCaptchaUseCase', () => {
  let service: VerifyReCaptchaUseCase;
  let mockReCaptchaRepository: Partial<GoogleReCaptchaClientPort>;

  beforeEach(async () => {
    mockReCaptchaRepository = {
      verify: jest.fn().mockImplementation((token) => {
        if (token === 'valid_token') {
          return Promise.resolve({ success: true });
        } else {
          return Promise.resolve({ success: false });
        }
      }),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        VerifyReCaptchaUseCase,
        {
          provide: GoogleReCaptchaClientPort,
          useValue: mockReCaptchaRepository,
        },
      ],
    }).compile();

    service = module.get<VerifyReCaptchaUseCase>(
      VerifyReCaptchaUseCase,
    );
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should verify token successfully', async () => {
    const req = {};
    await expect(
      service.verify('valid_token', req as any),
    ).resolves.toBeUndefined();
    expect(mockReCaptchaRepository.verify).toHaveBeenCalledWith(
      'valid_token',
      req,
    );
  });

  it('should throw HttpException on verification failure', async () => {
    const req = {};
    await expect(service.verify('invalid_token', req as any)).rejects.toThrow(
      HttpException,
    );
    expect(mockReCaptchaRepository.verify).toHaveBeenCalledWith(
      'invalid_token',
      req,
    );
  });
});
