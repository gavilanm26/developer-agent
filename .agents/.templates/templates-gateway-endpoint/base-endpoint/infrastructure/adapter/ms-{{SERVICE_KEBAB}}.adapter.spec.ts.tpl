import { Test, TestingModule } from '@nestjs/testing';
import { HttpService } from '@nestjs/axios';
import { of, throwError } from 'rxjs';
import { Request } from 'express';
import {
  AxiosResponse,
  InternalAxiosRequestConfig,
} from 'axios';

import { Ms{{SERVICE_PASCAL}}Adapter } from './ms-{{SERVICE_KEBAB}}.adapter';

describe('Ms{{SERVICE_PASCAL}}Adapter', () => {
  let service: Ms{{SERVICE_PASCAL}}Adapter;
  let httpService: HttpService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        Ms{{SERVICE_PASCAL}}Adapter,
        {
          provide: HttpService,
          useValue: {
            post: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<Ms{{SERVICE_PASCAL}}Adapter>(
      Ms{{SERVICE_PASCAL}}Adapter,
    );

    httpService = module.get<HttpService>(HttpService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should return expected response when status is 200', async () => {
    const mockPayload = { data: { documentNumber: '1234' } };

    const mockResponse: AxiosResponse = {
      data: { message: 'ok' },
      status: 200,
      statusText: 'OK',
      headers: {},
      config: {} as InternalAxiosRequestConfig,
    };

    jest
      .spyOn(httpService, 'post')
      .mockReturnValueOnce(of(mockResponse));

    const req: Request = {
      headers: {
        'x-tracking-op': 'tracking123',
      },
      clientIp: '127.0.0.1',
    } as any;

    const result = await service.{{METHOD_NAME}}(mockPayload as any, req);

    expect(result).toEqual({ message: 'ok' });
  });

  it('should return partial content response when status is 206', async () => {
    const mockPayload = { data: { documentNumber: '123' } };

    const mockResponse: AxiosResponse = {
      data: { message: 'partial content' },
      status: 206,
      statusText: 'Partial Content',
      headers: {},
      config: {} as InternalAxiosRequestConfig,
    };

    jest
      .spyOn(httpService, 'post')
      .mockReturnValueOnce(of(mockResponse));

    const req: Request = {
      headers: {
        'x-tracking-op': 'tracking123',
      },
      clientIp: '127.0.0.1',
    } as any;

    const result = await service.{{METHOD_NAME}}(mockPayload as any, req);

    expect(result).toEqual({
      message: 'partial content',
      statusCode: 206,
    });
  });

  it('should throw an error if the post request fails', async () => {
    const mockPayload = { data: { documentNumber: '123' } };

    const mockError = {
      response: {
        status: 500,
        data: 'Internal Server Error.',
      },
    };

    jest
      .spyOn(httpService, 'post')
      .mockReturnValueOnce(throwError(() => mockError));

    const req: Request = {
      headers: {
        'x-tracking-op': 'tracking123',
      },
      clientIp: '127.0.0.1',
    } as any;

    await expect(
      service.{{METHOD_NAME}}(mockPayload as any, req),
    ).rejects.toThrow();
  });
});