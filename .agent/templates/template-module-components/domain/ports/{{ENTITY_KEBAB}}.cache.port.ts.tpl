export abstract class {{ENTITY_PASCAL}}CachePort {
  abstract get(key: string): Promise<string | null>;
  abstract set(key: string, value: string): Promise<void>;
}
