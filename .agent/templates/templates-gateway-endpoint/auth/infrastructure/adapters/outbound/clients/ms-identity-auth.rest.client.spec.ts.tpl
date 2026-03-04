import { Test, TestingModule } from '@nestjs/testing';
import { HttpService } from '@nestjs/axios';
import { of } from 'rxjs';
import { MsIdentityAuthRestClient } from './ms-identity-auth.rest.client';
import { AuthRequestDto } from '../../../../domain/request';
import { Request } from 'express';

describe('MsIdentityAuthRestClient', () => {
  let service: MsIdentityAuthRestClient;
  let httpService: HttpService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MsIdentityAuthRestClient,
        {
          provide: HttpService,
          useValue: {
            post: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<MsIdentityAuthRestClient>(MsIdentityAuthRestClient);
    httpService = module.get<HttpService>(HttpService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should return the response from the httpService post call', async () => {
    const authRequestDto: AuthRequestDto = {
      data: {
        value: 'test',
        documentType: 'CC',
        documentNumber: '27279782',
        password: 'test',
      },
    };
    const response = { data: 'response' };

    const req: Request = {
      headers: {
        'X-Tracking-Op': '',
      },
      body: '',
    } as any;

    jest
      .spyOn(httpService, 'post')
      .mockImplementationOnce(() => of(response as any));

    expect(await service.validate(authRequestDto, req)).toEqual(response);
    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(httpService.post).toHaveBeenCalled();
  });

  it('should throw an error if the httpService post call fails', async () => {

    const authRequestDto: AuthRequestDto = { data: undefined };
    const error = { response: { data: 'error' } };
    const req: Request = {
      headers: {
        'X-Tracking-Op': '',
      },
      body: '',
    } as any;

    jest.spyOn(httpService, 'post').mockImplementationOnce(() => {
      // eslint-disable-next-line @typescript-eslint/only-throw-error
      throw error;
    });

    await expect(service.validate(authRequestDto, req)).rejects.toEqual(error);
    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(httpService.post).toHaveBeenCalled();
  });
});
