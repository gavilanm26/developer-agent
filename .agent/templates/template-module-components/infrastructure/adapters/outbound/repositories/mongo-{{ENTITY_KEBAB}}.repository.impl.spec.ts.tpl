import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';

import { Mongo{{ENTITY_PASCAL}}RepositoryImpl } from './mongo-{{ENTITY_KEBAB}}.repository.impl';
import { {{MONGO_SCHEMA_PASCAL}} } from '../../../persistence/schemas/{{ENTITY_KEBAB}}.schema';

jest.mock('@commons/http-logger/httpLogger', () => ({
  internalLogger:
    jest.fn(() => (source: any) =>
      source.pipe(require('rxjs/operators').map((res: any) => res.result))),
}));

describe('Mongo{{ENTITY_PASCAL}}RepositoryImpl', () => {
  let adapter: Mongo{{ENTITY_PASCAL}}RepositoryImpl;
  let model: any;

  beforeEach(async () => {
    model = { findOne: jest.fn() };

    const moduleRef: TestingModule = await Test.createTestingModule({
      providers: [
        Mongo{{ENTITY_PASCAL}}RepositoryImpl,
        {
          provide: getModelToken({{MONGO_SCHEMA_PASCAL}}.name),
          useValue: model,
        },
      ],
    }).compile();

    adapter = moduleRef.get(Mongo{{ENTITY_PASCAL}}RepositoryImpl);
  });

  it('should return mapped entity when document exists', async () => {
    model.findOne.mockReturnValue({
      exec: jest.fn().mockResolvedValue({
        id: '1',
        status: 'ACTIVE',
        payload: { ok: true },
      }),
    });

    const result = await adapter.findOne({ id: '1' } as any);

    expect(model.findOne).toHaveBeenCalledWith({ id: '1' });
    expect(result).toBeDefined();
  });

  it('should return null when document does not exist', async () => {
    model.findOne.mockReturnValue({
      exec: jest.fn().mockResolvedValue(null),
    });

    const result = await adapter.findOne({ id: 'x' } as any);

    expect(result).toBeNull();
  });
});
