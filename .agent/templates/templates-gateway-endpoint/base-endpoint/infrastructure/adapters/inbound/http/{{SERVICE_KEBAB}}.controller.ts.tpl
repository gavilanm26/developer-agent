import {
  Body,
  Controller,
  Post,
  Req,
  UseGuards,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import { Request } from 'express';
import { RequestDto } from '../../../../../dto/request';
import { {{SERVICE_PASCAL}}Usecase } from '../../../../application/ports/{{SERVICE_KEBAB}}.usecase.port';
// import { JwtAuthGuard } from '../../../../auth/infrastructure/guard/auth.guard'; // Descomentar si se usa JWT Guard

@Controller('v1')
export class {{SERVICE_PASCAL}}Controller {
  constructor(private readonly useCase: {{SERVICE_PASCAL}}Usecase) {}

  // @UseGuards(JwtAuthGuard)
  @Post('/{{SERVICE_KEBAB}}/execute') // <-- Ajustar este path según sea necesario
  @UsePipes(new ValidationPipe())
  async execute(@Body() body: RequestDto, @Req() req: Request) {
    return await this.useCase.execute(body, req);
  }
}
