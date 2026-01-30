import { ObjectType, Field } from '@nestjs/graphql';

@ObjectType()
export class ResponseModel {
  @Field()
  response: string;
}
