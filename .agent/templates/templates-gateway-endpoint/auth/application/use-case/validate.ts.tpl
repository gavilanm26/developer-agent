export class Validate {
  public token(token: string): boolean {
    const validTokens = [
      // 'token-unico-1',
      // 'token-unico-2',
      process.env.APPAUTHKEY,
    ];

    return validTokens.includes(token);
  }
}
