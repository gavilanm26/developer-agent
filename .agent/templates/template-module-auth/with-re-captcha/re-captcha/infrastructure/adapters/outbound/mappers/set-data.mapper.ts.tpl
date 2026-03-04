import { Injectable } from '@nestjs/common';

@Injectable()
export class SetDataMapper {
  queryString(token: string) {
    return `?secret=${process.env.INFRARECAPTCHASECRETKEY}&response=${token}`;
  }
}
