import { Test } from '@nestjs/testing';
import { TokenAdapter } from '@commons/token/adapter/token.adapter';
import { AuthTokenCommonsClient } from './auth-token-commons.client';

describe('AuthTokenCommonsClient', () => {
  let authTokenCommonsAdapter: AuthTokenCommonsClient;
  let mockTokenService: jest.Mocked<TokenAdapter>;

  beforeEach(async () => {
    const mockTokenServiceProvider = {
      provide: TokenAdapter,
      useValue: {
        get: jest.fn(),
      },
    };

    const moduleRef = await Test.createTestingModule({
      providers: [AuthTokenCommonsClient, mockTokenServiceProvider],
    }).compile();

    authTokenCommonsAdapter =
      moduleRef.get<AuthTokenCommonsClient>(AuthTokenCommonsClient);
    mockTokenService = moduleRef.get<TokenAdapter>(
      TokenAdapter,
    ) as jest.Mocked<TokenAdapter>;
  });

  it('should call TokenService.get', async () => {
    const expectedToken = {
      access_token: 'token',
      token_type: 'type',
      expires_in: 3600,
    };
    mockTokenService.get.mockResolvedValue({ data: expectedToken } as any);

    const token = await authTokenCommonsAdapter.get();

    expect(token.data).toBe(expectedToken);
    expect(mockTokenService.get).toHaveBeenCalledTimes(1);
  });
});
