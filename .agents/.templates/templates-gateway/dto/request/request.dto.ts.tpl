import { IsNotEmpty } from 'class-validator';

export class RequestDto {
  @IsNotEmpty()
  data: string;
}
