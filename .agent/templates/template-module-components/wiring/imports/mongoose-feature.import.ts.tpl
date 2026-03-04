import { MongooseModule } from '@nestjs/mongoose';
import { {{MONGO_SCHEMA_PASCAL}}, {{MONGO_MODEL_CONST}} } from '../../infrastructure/persistence/schemas/{{ENTITY_KEBAB}}.schema';

export const {{FEATURE_PASCAL}}MongooseFeatureImport = MongooseModule.forFeature([
  { name: {{MONGO_SCHEMA_PASCAL}}.name, schema: {{MONGO_MODEL_CONST}} },
]);
