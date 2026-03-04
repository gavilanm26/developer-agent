import * as CryptoJS from 'crypto-js';
import { createHash } from 'crypto';

export default class CryptoCore {
  private static key(key?: string) {
    return (
      key ??
      process.env.INFRAENCRYPTKEYCORE ??
      'ERROR APPENCRYPTKEYCORE NOT FOUND'
    );
  }

  static encrypt(data: string) {
    return CryptoJS.AES.encrypt(
      CryptoJS.enc.Utf8.parse(data),
      this.encryptMulesoftKey(),
      { mode: CryptoJS.mode.ECB, padding: CryptoJS.pad.Pkcs7 },
    ).toString(CryptoJS.format.Hex);
  }

  private static encryptMulesoftKey() {
    const hash = createHash('sha1')
      .update(this.key() || '')
      .digest();
    return this.convertUint8ArrayToWordArray(hash.subarray(0, 16));
  }

  private static convertUint8ArrayToWordArray(u8Array: Uint8Array) {
    const words: number[] = [];
    let i = 0;
    const len = u8Array.length;
    while (i < len) {
      words.push(
        (u8Array[i++] << 24) |
          (u8Array[i++] << 16) |
          (u8Array[i++] << 8) |
          u8Array[i++],
      );
    }
    return CryptoJS.lib.WordArray.create(words, words.length * 4);
  }
}
