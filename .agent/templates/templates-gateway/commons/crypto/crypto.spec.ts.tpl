import Crypto from './crypto';

describe('Encryption and Decryption', () => {
  const sampleData = { key: 'value' };
  const APPENCRYPTKEY = 'mysecretkey';

  it('should encrypt and decrypt an object correctly', () => {
    const encrypted = Crypto.encrypt(sampleData, APPENCRYPTKEY);
    const encrypted2 = Crypto.encrypt(sampleData);
    expect(encrypted).toBeTruthy();

    const decrypted = Crypto.decrypt(encrypted, APPENCRYPTKEY);
    Crypto.decrypt(encrypted2);
    expect(decrypted).toEqual(sampleData);
  });

  it('should return undefined when decrypting an empty input', () => {
    const decrypted = Crypto.decrypt('', APPENCRYPTKEY);
    expect(decrypted).toBeUndefined();
  });

  it('should return the string representation of the decrypted object', () => {
    Crypto.encrypt(sampleData);
    const encrypted = Crypto.encrypt(sampleData, APPENCRYPTKEY);
    Crypto.decrypt(encrypted, APPENCRYPTKEY);
  });

  it('should pad the key correctly to 64 characters in hexadecimal', () => {
    const keyHex = Crypto.getKeyHex(APPENCRYPTKEY);
    expect(keyHex).toHaveLength(64);
  });
});
