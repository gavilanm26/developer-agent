import { Test, TestingModule } from '@nestjs/testing';
import { HttpService } from '@nestjs/axios';
import { of } from 'rxjs';

import { ValidateOtcMapper } from '../../mappers/validate-otc.mapper';
import { AuthTokenCoreClient } from '../commons/auth-token-core.client';
import { ValidateOtcRestClient } from './validate-otc.rest.client';

describe('ValidateOtcRestClient', () => {
  let service: ValidateOtcRestClient;
  let mockHttpService: HttpService;
  let mockMapper: ValidateOtcMapper;
  let mockAuthTokenCoreClient: AuthTokenCoreClient;

  beforeAll(() => {
    process.env.APISECURITYMANAGEMENTURL = 'https://example.com';
  });

  beforeEach(async () => {
    mockHttpService = {
      post: jest.fn().mockReturnValue(of({ data: 'mockResponse' })),
    } as any;
    mockMapper = {
      request: jest.fn(),
      url: jest.fn().mockReturnValue('/validateOTC'),
      headers: jest.fn(),
    } as any;
    mockAuthTokenCoreClient = {
      get: jest.fn().mockReturnValue(Promise.resolve('mockToken')),
    } as any;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ValidateOtcRestClient,
        { provide: ValidateOtcMapper, useValue: mockMapper },
        { provide: AuthTokenCoreClient, useValue: mockAuthTokenCoreClient },
        { provide: HttpService, useValue: mockHttpService },
      ],
    }).compile();

    service = module.get<ValidateOtcRestClient>(ValidateOtcRestClient);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should make a POST request and return the response data', async () => {
    const data = {
      documentType: 'string',
      documentNumber: 'string',
      code: 'string',
      email: 'string',
      cellPhone: 'string',
    };
    const req = { headers: { 'x-tracking-op': 'someTrackingOp' } } as any;
    const result = await service.validate(data, req);

    expect(mockHttpService.post).toHaveBeenCalledWith(
      'https://example.com/V1/validateOTC',
      undefined,
      expect.anything(),
    );
    expect(result).toEqual('mockResponse');
  });
});
