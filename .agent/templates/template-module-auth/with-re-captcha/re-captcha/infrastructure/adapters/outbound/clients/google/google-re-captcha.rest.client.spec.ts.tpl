import { Test, TestingModule } from '@nestjs/testing';
import { HttpService } from '@nestjs/axios';
import { of } from 'rxjs';
import { AxiosHeaders, AxiosResponse } from 'axios';
import { GoogleReCaptchaRestClient } from '@modules/re-captcha/infrastructure/adapters/outbound/clients/google/google-re-captcha.rest.client';
import { SetDataMapper } from '@modules/re-captcha/infrastructure/adapters/outbound/mappers/set-data.mapper';

describe('GenerateOtpKycRepository', () => {
  let repository: GoogleReCaptchaRestClient;
  let httpService: HttpService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        GoogleReCaptchaRestClient,
        {
          provide: HttpService,
          useValue: {
            post: jest.fn(),
          },
        },
        {
          provide: SetDataMapper,
          useValue: {
            queryString: jest.fn(),
          },
        },
      ],
    }).compile();

    repository = module.get<GoogleReCaptchaRestClient>(
      GoogleReCaptchaRestClient,
    );
    httpService = module.get<HttpService>(HttpService);
  });

  it('should generate ProductsManagementActiveRepository with correct parameters', async () => {
    const data = {
      govIssueIdent: undefined,
      listProducts: [],
      personName: undefined,
      responseType: undefined,
    };

    const mockResponse: AxiosResponse<any> = {
      data: {
        data: data,
      },
      status: 200,
      statusText: 'OK',
      headers: {},
      config: {
        headers: {} as AxiosHeaders,
      },
    };

    const request = {
      headers: {
        'x-tracking-op': '123',
      },
    } as any;

    jest.spyOn(httpService, 'post').mockReturnValueOnce(of(mockResponse));

    const result = await repository.verify('token', request);

    expect(result).toEqual(mockResponse.data);
  });
});
