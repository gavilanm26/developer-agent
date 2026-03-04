import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UseInterceptors,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import type { Request } from 'express';
import { requiredHeaders } from '@commons/constants/headers.constants';
import { HeadersInterceptor } from '@commons/interceptor/headers.interceptor';
import { {{FEATURE_PASCAL}}Usecase } from '../../../../application/ports/{{FEATURE_KEBAB}}.usecase';
import { {{FEATURE_PASCAL}}HttpDto } from './dto/{{FEATURE_KEBAB}}.http.dto';

@Controller('v1')
export class {{FEATURE_PASCAL}}Controller {
  constructor(private readonly service: {{FEATURE_PASCAL}}Usecase) {}

  @Post('{{FEATURE_KEBAB}}')
  @UsePipes(new ValidationPipe())
  @UseInterceptors(new HeadersInterceptor(requiredHeaders))
  create(@Body() body: {{FEATURE_PASCAL}}HttpDto, @Req() req: Request) {
    return this.service.create(body as any, req);
  }

  @Get(':id')
  get(@Param('id') id: string, @Req() req: Request) {
    return this.service.get(id, req);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() body: {{FEATURE_PASCAL}}HttpDto, @Req() req: Request) {
    return this.service.update(id, body as any, req);
  }

  @Delete(':id')
  delete(@Param('id') id: string, @Req() req: Request) {
    return this.service.delete(id, req);
  }
}
