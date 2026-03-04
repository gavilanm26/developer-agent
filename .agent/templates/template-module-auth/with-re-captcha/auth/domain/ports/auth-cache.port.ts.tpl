import { Injectable } from '@nestjs/common';

@Injectable()
export abstract class AuthCachePort {
  abstract set(documentNumber: string): Promise<void>;
}
