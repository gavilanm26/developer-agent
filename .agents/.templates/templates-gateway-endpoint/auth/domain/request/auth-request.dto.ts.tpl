import { IsNotEmpty, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { ValuesDto } from './values.dto';

export class AuthRequestDto {
  @IsNotEmpty()
  @ValidateNested()
  @Type(() => ValuesDto)
  data: ValuesDto;
}
