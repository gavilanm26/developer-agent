import { UnauthorizedException } from '@nestjs/common';
import { JwtStrategy } from './jwt.strategy';

describe('JwtStrategy', () => {
  let jwtStrategy: JwtStrategy;

  beforeEach(() => {
    jwtStrategy = new JwtStrategy();
  });

  it('should be defined', () => {
    expect(jwtStrategy).toBeDefined();
  });

  it('should throw UnauthorizedException when validate payload is null', async () => {
    expect.assertions(1);
    let errorJWT: any;
    try {
      await jwtStrategy.validate(null);
    } catch (error) {
      errorJWT = error;
    }
    expect(errorJWT).toBeInstanceOf(UnauthorizedException);
  });

  it('should return payload when validate is called', async () => {
    const payload = { id: 1, username: 'testuser' };

    const result = await jwtStrategy.validate(payload);

    expect(result).toEqual(payload);
  });
});
