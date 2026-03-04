import { HttpException, HttpStatus } from '@nestjs/common';

export class IntegrationException extends HttpException {
  constructor(
    message: string,
    status: HttpStatus = HttpStatus.BAD_GATEWAY,
    public readonly originalError?: unknown,
  ) {
    super(message, status);
  }
}
