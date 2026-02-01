import { of } from 'rxjs';
import { HttpService } from '@nestjs/axios';
import { Ms{{SERVICE_PASCAL}}Adapter } from '../infrastructure/adapter/ms-{{SERVICE_KEBAB}}.adapter';

describe('Ms{{SERVICE_PASCAL}}Adapter', () => {
  let adapter: Ms{{SERVICE_PASCAL}}Adapter;

  const mockHttp = {
    post: jest.fn(),
  };

  beforeEach(() => {
    adapter = new Ms{{SERVICE_PASCAL}}Adapter(mockHttp as unknown as HttpService);
  });

  it('should call external service and return data', async () => {
    mockHttp.post.mockReturnValue(
      of({ data: { ok: true } }),
    );

    const result = await adapter.{{METHOD_NAME}}({} as any, { headers: {} } as any);

    expect(result).toEqual({ ok: true });
  });
});
