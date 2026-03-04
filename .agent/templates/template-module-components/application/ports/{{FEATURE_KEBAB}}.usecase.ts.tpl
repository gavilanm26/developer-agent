import { {{FEATURE_PASCAL}}RequestDto } from '../dto/{{FEATURE_KEBAB}}.request.dto';
import { {{FEATURE_PASCAL}}ResponseDto } from '../dto/{{FEATURE_KEBAB}}.response.dto';
import type { Request } from 'express';

export abstract class {{FEATURE_PASCAL}}Usecase {
  abstract create(input: {{FEATURE_PASCAL}}RequestDto, req: Request): Promise<{{FEATURE_PASCAL}}ResponseDto>;
  abstract get(id: string, req: Request): Promise<{{FEATURE_PASCAL}}ResponseDto>;
  abstract update(id: string, input: {{FEATURE_PASCAL}}RequestDto, req: Request): Promise<{{FEATURE_PASCAL}}ResponseDto>;
  abstract delete(id: string, req: Request): Promise<{{FEATURE_PASCAL}}ResponseDto>;
}
