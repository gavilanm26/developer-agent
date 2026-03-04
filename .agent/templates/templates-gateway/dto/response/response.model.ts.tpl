// <<GQL
import { ObjectType, Field } from '@nestjs/graphql';

@ObjectType()
// GQL>>
export class ResponseModel {
  // <<GQL
  @Field()
  // GQL>>
  response: string;
}