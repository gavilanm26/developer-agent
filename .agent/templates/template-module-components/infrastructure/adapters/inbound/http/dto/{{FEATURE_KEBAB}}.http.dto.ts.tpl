import { Type } from 'class-transformer';
import {
  IsNotEmpty,
  IsObject,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
// If customer ownership uses `documentType`, import and use:
// import { TypeOfDocuments } from '@commons/enums/type-of-documents.enum';
// and type that field as `TypeOfDocuments` instead of `string`.

export class {{FEATURE_PASCAL}}FactsHttpDto {
  @IsString()
  @IsNotEmpty()
  idClientType!: string;

  @IsString()
  @IsNotEmpty()
  idTypeFlow!: string;

  [key: string]: any;
}

export class {{FEATURE_PASCAL}}HttpDto {
  // Reuse this file across CRUD endpoints; include one or more DTO classes as needed.
  @IsObject()
  @IsOptional()
  @ValidateNested()
  @Type(() => {{FEATURE_PASCAL}}FactsHttpDto)
  facts?: {{FEATURE_PASCAL}}FactsHttpDto;

  @IsObject()
  @IsOptional()
  context?: Record<string, any>;
}
