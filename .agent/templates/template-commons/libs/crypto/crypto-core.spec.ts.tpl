import { createHash } from 'crypto';
import CryptoCore from './crypto-core';

describe('CryptoCore', () => {
  let originalEnv: NodeJS.ProcessEnv;

  beforeAll(() => {
    originalEnv = process.env;
    process.env = { ...originalEnv, INFRAENCRYPTKEYCORE: 'testKey' };
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  it('should return an encrypted string', () => {
    const data = 'testData';
    const encrypted = CryptoCore.encrypt(data);
    expect(typeof encrypted).toBe('string');
  });

  it('should return a word array', () => {
    const hash = createHash('sha1').update('testKey').digest();
    const u8Array = hash.slice(0, 16);

    const spy = jest
      .spyOn(CryptoCore, 'encryptMulesoftKey' as any)
      .mockReturnValue(u8Array);

    CryptoCore.encrypt('testData');

    expect(spy).toHaveBeenCalled();
    spy.mockRestore();
  });

  it('should return the environment key when no key is provided', () => {
    const encryptedData = CryptoCore.encrypt('secret data');
    expect(encryptedData).toBeDefined();
  });
});
