import { TypeOfDocuments } from '@commons/enums/type-of-documents.enum';
import { IsEnum, IsNotEmpty, IsString } from 'class-validator';

export class ValidateOtcHttpDto {
  @IsEnum(TypeOfDocuments)
  @IsNotEmpty()
  documentType: TypeOfDocuments;

  @IsString()
  @IsNotEmpty()
  documentNumber: string;

  @IsNotEmpty()
  @IsString()
  code: string;
}
