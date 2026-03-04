import { Test, TestingModule } from '@nestjs/testing';
import type { AxiosResponse, InternalAxiosRequestConfig } from 'axios';
import type { Request } from 'express';

import { GetBasicDataClient } from './get-basic-data.client';
import { GetBasicDataImplAdapter } from '@commons/basic-data/adapter/get-basic-data.impl.adapter';
import { BasicDataRequestModel } from '../../../../../domain/models/basic-data-request.model';

describe('GetBasicDataClient', () => {
  let service: GetBasicDataClient;
  let basicDataImpl: GetBasicDataImplAdapter;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        GetBasicDataClient,
        {
          provide: GetBasicDataImplAdapter,
          useValue: {
            get: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<GetBasicDataClient>(GetBasicDataClient);
    basicDataImpl = module.get<GetBasicDataImplAdapter>(
      GetBasicDataImplAdapter,
    );
  });

  it('debe estar definido', () => {
    expect(service).toBeDefined();
    expect(basicDataImpl).toBeDefined();
  });

  it('debe llamar a GetBasicDataImplAdapter.get() correctamente', async () => {
    const mockRequest = {
      headers: { 'x-tracking-op': '123' },
    } as unknown as Request;

    const mockBody: BasicDataRequestModel = {
      documentNumber: '1007406331',
      documentType: 'CC',
      transactionName: 'Test Transaction',
    };

    const mockRes: AxiosResponse = {
      data: { emailAddr: 'test@example.com', cellPhone: '123456789' },
      status: 200,
      statusText: 'OK',
      headers: {},
      config: {} as InternalAxiosRequestConfig,
    };

    jest.spyOn(basicDataImpl, 'get').mockReturnValue(Promise.resolve(mockRes));

    const result = await service.get(mockBody, mockRequest);

    const { transactionName, ...expectedBody } = mockBody;
    expect(basicDataImpl.get).toHaveBeenCalledWith(expectedBody, mockRequest);
    expect(result).toEqual(mockRes.data);
  });

  it('debe manejar errores de GetBasicDataImplAdapter.get().', async () => {
    const mockRequest = {
      headers: { 'x-tracking-op': '123' },
    } as unknown as Request;

    const mockBody: BasicDataRequestModel = {
      documentNumber: '1007406331',
      documentType: 'CC',
      transactionName: 'Test Transaction',
    };

    const mockError = new Error('Request failed');
    jest.spyOn(basicDataImpl, 'get').mockReturnValue(Promise.reject(mockError));

    await expect(service.get(mockBody, mockRequest)).rejects.toThrow(
      'Request failed',
    );
  });
});
