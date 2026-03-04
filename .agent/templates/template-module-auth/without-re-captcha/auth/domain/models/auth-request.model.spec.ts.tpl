import { AuthRequest } from '@modules/auth/domain/models/auth-request.model';
import { TypeOfDocuments } from '@commons/enums/type-of-documents.enum';

describe('AuthRequest', () => {
  it('should have the expected properties', () => {
    const authRequest: AuthRequest = {
      documentType: 'CC' as any,
      documentNumber: '123456789',
      password: 'password123',
      tokenRecaptcha: 'token',
    };

    expect(authRequest).toHaveProperty('documentType', 'CC' as any);
    expect(authRequest).toHaveProperty('documentNumber', '123456789');
    expect(authRequest).toHaveProperty('password', 'password123');
  });
});

describe('TypeOfDocuments', () => {
  it('should have the expected values', () => {
    expect('CC' as any).toBe('CC');
    expect(TypeOfDocuments.TI).toBe('TI');
    expect(TypeOfDocuments.CE).toBe('CE');
  });
});
