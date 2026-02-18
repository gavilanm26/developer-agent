import { Test, TestingModule } from '@nestjs/testing';
import { {{SERVICE_PASCAL}}Controller } from './{{SERVICE_KEBAB}}.controller';
import { {{SERVICE_PASCAL}}Service } from '../../domain/{{SERVICE_KEBAB}}.service';

describe('{{SERVICE_PASCAL}}Controller', () => {
  let controller: {{SERVICE_PASCAL}}Controller;

  const mockService = {
    execute: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [{{SERVICE_PASCAL}}Controller],
      providers: [
        {
          provide: {{SERVICE_PASCAL}}Service,
          useValue: mockService,
        },
      ],
    }).compile();

    controller = module.get({{SERVICE_PASCAL}}Controller);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should call service.execute', async () => {
    const body = {} as any;
    const req = {} as any;

    mockService.execute.mockResolvedValue({});

    await controller.execute(body, req);

    expect(mockService.execute).toHaveBeenCalledWith(body, req);
  });
});
