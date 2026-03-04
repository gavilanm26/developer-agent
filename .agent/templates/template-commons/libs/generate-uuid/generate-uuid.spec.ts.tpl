import { UuidGenerator } from './generate-uuid';

describe('UuidGenerator', () => {
  it('should generate a valid UUID string', () => {
    const uuid = UuidGenerator.generate();

    expect(typeof uuid).toBe('string');
    expect(uuid).toMatch(
      /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i,
    );
  });

  it('should generate different UUIDs on each call', () => {
    const uuid1 = UuidGenerator.generate();
    const uuid2 = UuidGenerator.generate();

    expect(uuid1).not.toEqual(uuid2);
  });
});
