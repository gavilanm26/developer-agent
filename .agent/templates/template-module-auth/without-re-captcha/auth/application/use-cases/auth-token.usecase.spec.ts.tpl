import { AuthTokenUseCase } from './auth-token.usecase';
import { CoreAuthClientPort } from '@modules/auth/domain/ports/core-auth.client.port';
import { AuthRequest } from '@modules/auth/domain/models/auth-request.model';
import { Request } from 'express';
import { ReCaptchaUsecase } from '@modules/re-captcha/application/ports/re-captcha.usecase';
import { AuthCachePort } from '@modules/auth/domain/ports/auth-cache.port';
import { TypeOfDocuments } from '@commons/enums/type-of-documents.enum';

describe('AuthTokenUseCase', () => {
  let generateTokenService: AuthTokenUseCase;
  let authRepository: jest.Mocked<CoreAuthClientPort>;
  let reCaptchaService: jest.Mocked<ReCaptchaUsecase>;
  let authCache: jest.Mocked<AuthCachePort>;

  beforeEach(() => {
    authRepository = {
      auth: jest.fn(),
    } as jest.Mocked<CoreAuthClientPort>;

    reCaptchaService = {
      verify: jest.fn(),
    } as jest.Mocked<ReCaptchaUsecase>;

    authCache = {
      set: jest.fn(),
    } as jest.Mocked<AuthCachePort>;

    generateTokenService = new AuthTokenUseCase(
      authRepository,
      reCaptchaService,
      authCache,
    );
  });

  describe('token', () => {


    it('should call authRepository.auth with the correct authRequest', async () => {
      const authRequest: AuthRequest = {
        documentNumber: '987654321',
        documentType: TypeOfDocuments.CE,
        password: 'securePassword321',
        tokenRecaptcha: 'some-token',
      };

      const req: Request = {
        body: {},
        headers: {},
      } as Request;

      reCaptchaService.verify.mockResolvedValueOnce(undefined);
      authRepository.auth.mockResolvedValueOnce(undefined);

      await generateTokenService.token(authRequest, req);

      expect(authRepository.auth.mock.calls[0]).toEqual([authRequest, req]);
    });

    it('should call authCache.set with the correct documentNumber', async () => {
      const authRequest: AuthRequest = {
        password: '12345678',
        documentType: TypeOfDocuments.CE,
        documentNumber: '123456',
        tokenRecaptcha: 'some-token',
      };

      const req: Request = {
        body: {},
        headers: {},
      } as Request;

      reCaptchaService.verify.mockResolvedValueOnce(undefined);
      authRepository.auth.mockResolvedValueOnce(undefined);

      await generateTokenService.token(authRequest, req);

      expect(authCache.set.mock.calls[0]).toEqual(['123456']);
    });
  });
});
