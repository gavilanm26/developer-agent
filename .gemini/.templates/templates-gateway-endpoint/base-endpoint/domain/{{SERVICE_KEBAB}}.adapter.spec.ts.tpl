import { {{SERVICE_PASCAL}}Adapter } from './{{SERVICE_KEBAB}}.adapter';

describe('{{SERVICE_PASCAL}}Adapter (port)', () => {
  it('should be defined', () => {
    expect({{SERVICE_PASCAL}}Adapter).toBeDefined();
  });

  it('should declare {{METHOD_NAME}} method', () => {
    const methods = Object.getOwnPropertyNames(
      {{SERVICE_PASCAL}}Adapter.prototype,
    );

    expect(methods).toContain('{{METHOD_NAME}}');
  });
});
