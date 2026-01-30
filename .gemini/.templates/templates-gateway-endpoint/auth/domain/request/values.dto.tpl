import { IsNotEmpty } from 'class-validator';

export class ValuesDto {
  @IsNotEmpty()
  value: string;

  @IsNotEmpty()
  documentType: string;

  @IsNotEmpty()
  documentNumber: string;

  @IsNotEmpty()
  password: string;
}
