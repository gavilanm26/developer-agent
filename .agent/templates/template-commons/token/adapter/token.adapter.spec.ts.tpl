import { TokenAdapter } from './token.adapter';
import { HttpService } from '@nestjs/axios';
import { of } from 'rxjs';

const originalEnv = process.env.IDENTITYMANAGEMENT;
process.env.IDENTITYMANAGEMENT = 'mocked-encrypt-key';
describe('TokenAdapter', () => {
  let tokenAdapter: TokenAdapter;
  let httpServiceMock: jest.Mocked<HttpService>;

  afterAll(() => {
    process.env.ENCRYPTKEYKYC = originalEnv;
  });

  beforeEach(() => {
    httpServiceMock = {
      post: jest.fn().mockReturnValue(of({ data: 'test_token' })),
    } as unknown as jest.Mocked<HttpService>;

    tokenAdapter = new TokenAdapter(httpServiceMock);
  });

  describe('get', () => {
    it('should return the token data', async () => {
      const result = await tokenAdapter.get();

      expect(result.data).toBe('test_token');
    });
  });
});
