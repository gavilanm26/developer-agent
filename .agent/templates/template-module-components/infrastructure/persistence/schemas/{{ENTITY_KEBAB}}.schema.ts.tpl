import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema({ collection: '{{MONGO_COLLECTION}}', timestamps: true })
export class {{MONGO_SCHEMA_PASCAL}} extends Document {
  @Prop({ required: true })
  id!: string;

  @Prop({ required: true })
  status!: string;

  @Prop({ type: Object })
  payload?: Record<string, any>;
}

export const {{MONGO_MODEL_CONST}} = SchemaFactory.createForClass({{MONGO_SCHEMA_PASCAL}});

// Add domain-specific indexes in generated modules if needed.
