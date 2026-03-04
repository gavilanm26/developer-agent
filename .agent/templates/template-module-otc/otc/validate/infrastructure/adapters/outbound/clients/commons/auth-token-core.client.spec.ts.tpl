import { Test } from '@nestjs/testing';

import { AuthTokenCoreClient } from './auth-token-core.client';
import { TokenAdapter } from '@commons/token/adapter/token.adapter';

describe('AuthTokenCoreClient', () => {
  let authTokenCoreClient: AuthTokenCoreClient;
  let mockTokenAdapter: jest.Mocked<TokenAdapter>;

  beforeEach(async () => {
    const mockTokenAdapterProvider = {
      provide: TokenAdapter,
      useValue: {
        get: jest.fn(),
      },
    };

    const moduleRef = await Test.createTestingModule({
      providers: [AuthTokenCoreClient, mockTokenAdapterProvider],
    }).compile();

    authTokenCoreClient =
      moduleRef.get<AuthTokenCoreClient>(AuthTokenCoreClient);
    mockTokenAdapter = moduleRef.get<TokenAdapter>(
      TokenAdapter,
    ) as jest.Mocked<TokenAdapter>;
  });

  it('should call TokenAdapter.get', async () => {
    const expectedToken = {
      access_token: 'token',
      token_type: 'type',
      expires_in: 3600,
    };
    mockTokenAdapter.get.mockResolvedValue(expectedToken);

    const token = await authTokenCoreClient.get();

    expect(token).toBe(expectedToken);
    expect(mockTokenAdapter.get).toHaveBeenCalledTimes(1);
  });
});
