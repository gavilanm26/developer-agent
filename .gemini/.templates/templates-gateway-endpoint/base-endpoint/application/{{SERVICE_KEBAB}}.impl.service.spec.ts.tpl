import { {{SERVICE_PASCAL}}ImplService } from './{{SERVICE_KEBAB}}.impl.service';

describe('{{SERVICE_PASCAL}}ImplService', () => {
  let service: {{SERVICE_PASCAL}}ImplService;

  const mockDomain = {
    {{METHOD_NAME}}: jest.fn(),
  };

  beforeEach(() => {
    service = new {{SERVICE_PASCAL}}ImplService(mockDomain as any);
  });

  it('should call domain service', async () => {
    const body = {} as any;
    const req = {} as any;

    await service.execute(body, req);

    expect(mockDomain.{{METHOD_NAME}}).toHaveBeenCalledWith(body, req);
  });
});
