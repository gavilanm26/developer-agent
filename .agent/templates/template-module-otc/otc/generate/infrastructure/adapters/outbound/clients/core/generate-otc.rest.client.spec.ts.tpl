import { Test, TestingModule } from '@nestjs/testing';
import { HttpService } from '@nestjs/axios';
import { of } from 'rxjs';
import type { Request } from 'express';

import { GenerateOtcRestClient } from './generate-otc.rest.client';
import { GenerateOtcMapper } from '../../mappers/generate-otc.mapper';
import { AuthTokenCoreClient } from '../commons/auth-token-core.client';

describe('GenerateOtcRestClient', () => {
  let repository: GenerateOtcRestClient;
  let httpService: HttpService;
  let authTokenCoreClient: AuthTokenCoreClient;

  const mockMapper = {
    request: jest.fn().mockReturnValue({}),
    url: jest.fn().mockReturnValue('/generateOTC'),
    headers: jest.fn().mockReturnValue({}),
  };

  beforeEach(async () => {
    const mockHttpService = {
      post: jest.fn(),
    };

    const mockAuthTokenCoreClient = {
      get: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        GenerateOtcRestClient,
        { provide: GenerateOtcMapper, useValue: mockMapper },
        { provide: HttpService, useValue: mockHttpService },
        { provide: AuthTokenCoreClient, useValue: mockAuthTokenCoreClient },
      ],
    }).compile();

    repository = module.get<GenerateOtcRestClient>(
      GenerateOtcRestClient,
    );
    httpService = module.get<HttpService>(HttpService);
    authTokenCoreClient = module.get<AuthTokenCoreClient>(AuthTokenCoreClient);
  });

  it('should be defined', () => {
    expect(repository).toBeDefined();
  });

  it('should call httpService.post with correct parameters', async () => {
    const mockData = {
      documentType: 'string',
      documentNumber: 'string',
      transactionName: 'string',
      email: 'string',
      cellPhone: 'string',
    };
    const mockReq: Request = {
      headers: {
        'x-tracking-op': 'mockTrackingOp',
      },
    } as any;
    const mockToken = 'mockToken';
    const mockResponse = { data: 'response' };

    mockMapper.request.mockReturnValueOnce({});
    mockMapper.url.mockReturnValueOnce('/generateOTC');
    mockMapper.headers.mockReturnValueOnce({});

    (authTokenCoreClient.get as jest.Mock).mockResolvedValueOnce(mockToken);

    (httpService.post as jest.Mock).mockReturnValueOnce(
      of({ data: mockResponse }),
    );

    const result = await repository.generate(mockData, mockReq);

    expect(httpService.post).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Object),
      expect.objectContaining({
        headers: expect.objectContaining({}),
      }),
    );
    expect(result).toEqual(mockResponse);
  });
});
