import { IsNotEmpty, IsString } from 'class-validator';
import { TypeOfDocuments } from '@commons/enums/type-of-documents.enum';

export class AuthHttpDto {
  @IsString()
  @IsNotEmpty()
  documentNumber: string;

  @IsString()
  @IsNotEmpty()
  documentType: TypeOfDocuments;

  @IsString()
  @IsNotEmpty()
  password: string;

  @IsString()
  @IsNotEmpty()
  tokenRecaptcha: string;
}
