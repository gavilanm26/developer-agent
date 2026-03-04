export class UuidGenerator {
  static generate(): string {
    return crypto.randomUUID();
  }
}
