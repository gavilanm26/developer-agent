import { Injectable } from '@nestjs/common';
import { AuthRequestDto } from './request';
import { ResponseDto } from '../../../dto/response';
import { Request } from 'express';

@Injectable()
export abstract class AuthService {
  abstract createToken(
    payload: AuthRequestDto,
    req: Request,
  ): Promise<ResponseDto>;
}
