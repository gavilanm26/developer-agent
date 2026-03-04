import { TypeOfDocuments } from '@commons/enums/type-of-documents.enum';
import { IsEnum, IsNotEmpty, IsString } from 'class-validator';

export class GenerateOtcHttpDto {
  @IsEnum(TypeOfDocuments)
  @IsNotEmpty()
  documentType: TypeOfDocuments;

  @IsString()
  @IsNotEmpty()
  documentNumber: string;

  @IsString()
  @IsNotEmpty()
  transactionName: string;
}
