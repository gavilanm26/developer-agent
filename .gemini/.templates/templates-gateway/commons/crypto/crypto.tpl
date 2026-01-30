import * as crypto from 'crypto';

export default class Crypto {
  private static key(key?: string, useSecondKey: boolean = false): string {
    return (
      key ||
      process.env[useSecondKey ? 'APPENCRYPTKEYTWO' : 'APPENCRYPTKEY'] ||
      ''
    );
  }

  static getKeyHex(key: string) {
    const hexKey = Buffer.from(
      key.repeat(Math.ceil(32 / key.length)).slice(0, 32),
    ).toString('hex');
    return hexKey.padEnd(64, '0');
  }

  static decrypt(item: any, otherKey?: string) {
    try {
      if (!item) {
        return;
      }

      const keyHex = this.getKeyHex(this.key(otherKey, false));
      const key = Buffer.from(keyHex, 'hex');

      const parts = item.split(':');
      const iv = Buffer.from(parts.shift(), 'hex');
      const authTag = Buffer.from(parts.shift(), 'hex');
      const encryptedData = parts.join(':');

      const decipher = crypto.createDecipheriv('aes-256-gcm', key, iv);
      decipher.setAuthTag(authTag);

      let decrypted = decipher.update(encryptedData, 'hex', 'utf8');
      decrypted += decipher.final('utf8');

      return JSON.parse(decrypted);
    } catch (error) {
      console.error('Decryption error:', JSON.stringify(error));
    }
  }

  static encrypt(item: any, otherKey?: string) {
    try {
      const keyHex = this.getKeyHex(this.key(otherKey, true));
      const key = Buffer.from(keyHex, 'hex');

      const iv = crypto.randomBytes(12);
      const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);

      let encrypted = cipher.update(JSON.stringify(item), 'utf8', 'hex');
      encrypted += cipher.final('hex');

      const authTag = cipher.getAuthTag().toString('hex');

      return `${iv.toString('hex')}:${authTag}:${encrypted}`;
    } catch (error) {
      console.error('Encryption error:', JSON.stringify(error));
    }
  }
}
