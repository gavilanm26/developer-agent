import { {{SERVICE_PASCAL}}Service } from './{{SERVICE_KEBAB}}.service';

describe('{{SERVICE_PASCAL}}Service (port)', () => {
  it('should be defined', () => {
    expect({{SERVICE_PASCAL}}Service).toBeDefined();
  });

  it('should be an abstract class', () => {
    expect({{SERVICE_PASCAL}}Service.prototype.constructor).toBeDefined();
    expect({{SERVICE_PASCAL}}Service.name).toBe('{{SERVICE_PASCAL}}Service');
  });
});