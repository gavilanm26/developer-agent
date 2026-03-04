import { Validate } from './validate';

describe('Validate', () => {
  let validate: Validate;

  beforeEach(() => {
    validate = new Validate();
  });

  it('should return false if the token is invalid', () => {
    const token = 'invalid-token';

    const result = validate.token(token);

    expect(result).toBe(false);
  });

  it('should return true if the token matches the environment variable', () => {
    const token = process.env.APPAUTHKEY;

    const result = validate.token(token);

    expect(result).toBe(true);
  });
});
