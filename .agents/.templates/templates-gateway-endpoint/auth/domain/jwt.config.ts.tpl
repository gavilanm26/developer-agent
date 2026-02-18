import { Algorithm } from 'jsonwebtoken';

const privateKeyBase64: string =
  process.env.APPTOKENGUARDPRIVATE ?? 'APPTOKENGUARDPRIVATE variable not found';
const publicKeyBase64: string =
  process.env.APPJWTPUBLIC ?? 'APPJWTPUBLIC variable not found';

export default {
  privateKey: privateKeyBase64
    ? Buffer.from(privateKeyBase64, 'base64').toString('binary')
    : 'secret',
  publicKey: publicKeyBase64
    ? Buffer.from(publicKeyBase64, 'base64').toString('binary')
    : 'public',
  expiresIn: process.env.APPJWTEXPIRESIN ?? '1h',
  algorithm: 'RS256' as Algorithm,
};
