export abstract class OtcStateCachePort {
  abstract set(processId: string): Promise<void>;
}
