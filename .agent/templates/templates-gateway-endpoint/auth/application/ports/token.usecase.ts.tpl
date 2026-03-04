import { Injectable } from '@nestjs/common';
import { AuthRequestDto } from '../../domain/request';
import { ResponseDto } from '@app/dto/response';
import { Request } from 'express';

@Injectable()
export abstract class TokenUsecase {
  abstract sign(payload: AuthRequestDto, req: Request): Promise<ResponseDto>;
}
