import { Test, TestingModule } from '@nestjs/testing';
import { HttpService } from '@nestjs/axios';
import { of } from 'rxjs';
import type { AxiosResponse } from 'axios';

import { {{EXTERNAL_PASCAL}}RestClient } from './{{EXTERNAL_KEBAB}}.rest.client';

describe('{{EXTERNAL_PASCAL}}RestClient', () => {
  let adapter: {{EXTERNAL_PASCAL}}RestClient;
  let httpService: jest.Mocked<HttpService>;

  beforeEach(async () => {
    process.env.{{BASE_URL_ENV}} = 'http://localhost:3001';

    httpService = {
      post: jest.fn(),
    } as unknown as jest.Mocked<HttpService>;

    const moduleRef: TestingModule = await Test.createTestingModule({
      providers: [
        {{EXTERNAL_PASCAL}}RestClient,
        { provide: HttpService, useValue: httpService },
      ],
    }).compile();

    adapter = moduleRef.get({{EXTERNAL_PASCAL}}RestClient);
  });

  afterEach(() => {
    delete process.env.{{BASE_URL_ENV}};
    jest.clearAllMocks();
  });

  it('should call remote service and return response data', async () => {
    const mockResponse = {
      data: { ok: true },
      status: 200,
      statusText: 'OK',
      headers: {},
      config: { headers: {} as any },
    } as AxiosResponse<any>;

    httpService.post.mockReturnValueOnce(of(mockResponse));

    const result = await adapter.{{METHOD_NAME}}(
      { documentNumber: '123' } as any,
      { headers: { 'x-tracking-op': 'track-1' } } as any,
    );

    expect(httpService.post).toHaveBeenCalled();
    expect(result).toEqual({ ok: true });
  });
});
