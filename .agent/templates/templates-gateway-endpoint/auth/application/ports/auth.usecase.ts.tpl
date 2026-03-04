import { Injectable } from '@nestjs/common';
import { AuthRequestDto } from '../../domain/request';
import { ResponseDto } from '@app/dto/response';
import { Request } from 'express';

@Injectable()
export abstract class AuthUsecase {
  abstract createToken(
    payload: AuthRequestDto,
    req: Request,
  ): Promise<ResponseDto>;
}
