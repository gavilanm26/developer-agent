import { Test, TestingModule } from '@nestjs/testing';
import { HttpService } from '@nestjs/axios';
import { Observable, of } from 'rxjs';
import { AuthRequest } from '@modules/auth/domain/models/auth-request.model';
import { AuthCoreRestClient } from './auth-core.rest.client';
import { SetDataMapper } from '@modules/auth/infrastructure/adapters/outbound/mappers/set-data.mapper';
import { AuthTokenCommonsClient } from '../commons/auth-token-commons.client';
import { AxiosError, AxiosHeaders, AxiosResponse } from 'axios';
import { TypeOfDocuments } from '@commons/enums/type-of-documents.enum';
import { HttpException } from '@nestjs/common';
import { Request } from 'express';

describe('AuthCoreRestClient', () => {
  let service: AuthCoreRestClient;
  let httpService: HttpService;
  let authTokenCommonsAdapter: AuthTokenCommonsClient;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthCoreRestClient,
        {
          provide: HttpService,
          useValue: {
            post: jest.fn(),
          },
        },
        {
          provide: SetDataMapper,
          useValue: {
            request: jest.fn(),
            headers: jest.fn(),
          },
        },
        {
          provide: AuthTokenCommonsClient,
          useValue: {
            get: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<AuthCoreRestClient>(AuthCoreRestClient);
    httpService = module.get<HttpService>(HttpService);
    authTokenCommonsAdapter =
      module.get<AuthTokenCommonsClient>(AuthTokenCommonsClient);
  });

  it('should call httpService with correct parameters', async () => {
    const mockAuthRequest: AuthRequest = {
      documentNumber: '123456789',
      password: '',
      documentType: TypeOfDocuments.CC,
      tokenRecaptcha: '',
    };
    const response: AxiosResponse = {
      data: {
        access_token: 'token',
        token_type: 'Bearer',
        expires_in: 3600,
      },
      status: 200,
      statusText: 'OK',
      headers: {},
      config: {
        headers: {} as any,
      },
    };

    const mockToken = 'mockToken';
    const mockUrl = 'mockUrl';

    jest
      .spyOn(authTokenCommonsAdapter, 'get')
      .mockResolvedValueOnce(mockToken as any);
    jest.spyOn(httpService, 'post').mockReturnValueOnce(of(response));
    process.env.APIAUTHURL = mockUrl;
    const mockRequest = {
      headers: {
        'x-tracking-op': '',
      },
      get: jest.fn().mockImplementation((header: string) => {
        return mockRequest.headers[header.toLowerCase()];
      }),
      params: {},
      query: {},
      body: {},
    } as unknown as Request;

    await service.auth(mockAuthRequest, mockRequest);
  });

  it('should handle error from httpService', async () => {
    const mockAuthRequest: AuthRequest = {
      documentNumber: '12345678',
      password: '',
      documentType: TypeOfDocuments.CC,
      tokenRecaptcha: '',
    };
    const mockToken = {
      access_token: '',
      expires_in: 0,
      token_type: '',
    };
    const mockError: AxiosError = {
      config: {
        headers: {} as any,
      },
      isAxiosError: true,
      toJSON: () => ({}),
      name: '',
      message: 'Error',
      response: {
        status: 500,
        statusText: 'Server Error',
        headers: { 'x-tracking-op': '' },
        config: {
          headers: {} as any,
        },
        data: 'Error',
      },
    };

    jest
      .spyOn(authTokenCommonsAdapter, 'get')
      .mockResolvedValueOnce({ data: mockToken } as any);
    jest.spyOn(httpService, 'post').mockImplementation(() => {
      return new Observable((subscriber) => {
        subscriber.error(mockError);
      });
    });
    const mockRequest = {
      headers: {
        'x-tracking-op': '',
      },
      get: jest.fn().mockImplementation((header: string) => {
        return mockRequest.headers[header.toLowerCase()];
      }),
      params: {},
      query: {},
      body: {},
    } as unknown as Request;

    await expect(service.auth(mockAuthRequest, mockRequest)).rejects.toThrow(
      new HttpException('Error', mockError.response?.status ?? 500),
    );
  });
});
