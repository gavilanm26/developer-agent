import { TypeOfDocuments } from '@commons/enums/type-of-documents.enum';

export interface AuthRequest {
  documentType: TypeOfDocuments;
  documentNumber: string;
  password: string;
  tokenRecaptcha: string;
}
