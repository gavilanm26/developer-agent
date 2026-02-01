import { {{SERVICE_PASCAL}}Service } from '../domain/{{SERVICE_KEBAB}}.service';

describe('{{SERVICE_PASCAL}}Service', () => {
  let service: {{SERVICE_PASCAL}}Service;

  const mockAdapter = {
    {{METHOD_NAME}}: jest.fn(),
  };

  beforeEach(() => {
    service = new {{SERVICE_PASCAL}}Service(mockAdapter as any);
  });

  it('should delegate call to adapter', async () => {
    const body = {} as any;
    const req = {} as any;

    await service.{{METHOD_NAME}}(body, req);

    expect(mockAdapter.{{METHOD_NAME}}).toHaveBeenCalledWith(body, req);
  });
});
