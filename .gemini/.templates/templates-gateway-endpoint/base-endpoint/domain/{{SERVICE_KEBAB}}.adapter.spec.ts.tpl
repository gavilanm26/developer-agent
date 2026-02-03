import { {{SERVICE_PASCAL}}Adapter } from './{{SERVICE_KEBAB}}.adapter';

describe('{{SERVICE_PASCAL}}Adapter (port)', () => {
  it('should be defined', () => {
    expect({{SERVICE_PASCAL}}Adapter).toBeDefined();
  });

  it('should be an abstract class', () => {
    expect({{SERVICE_PASCAL}}Adapter.prototype.constructor).toBeDefined();
    expect({{SERVICE_PASCAL}}Adapter.name).toBe('{{SERVICE_PASCAL}}Adapter');
  });
});
