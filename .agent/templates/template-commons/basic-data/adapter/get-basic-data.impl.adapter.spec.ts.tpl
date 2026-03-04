import { HttpService } from '@nestjs/axios';
import { of } from 'rxjs';
import { Request } from 'express';

import { GetBasicDataImplAdapter } from './get-basic-data.impl.adapter';

describe('GetBasicDataImplAdapter', () => {
  let adapter: GetBasicDataImplAdapter;
  let httpServiceMock: jest.Mocked<HttpService>;

  beforeEach(() => {
    process.env.APIURLCOMMONSBASICDATA = 'https://mock-basic-data';

    httpServiceMock = {
      post: jest.fn().mockReturnValue(of({ data: { ok: true } })),
    } as unknown as jest.Mocked<HttpService>;

    adapter = new GetBasicDataImplAdapter(httpServiceMock);
  });

  it('should request basic data and return response', async () => {
    const req = { headers: { 'x-tracking-op': '123' } } as unknown as Request;

    const result = await adapter.get({ documentType: 'CC' }, req);

    expect(httpServiceMock.post).toHaveBeenCalledTimes(1);
    expect(result.data).toEqual({ ok: true });
  });
});
