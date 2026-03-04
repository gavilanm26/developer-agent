import { Injectable } from '@nestjs/common';
import type { Request } from 'express';
import { CommonHeaders } from '../../../../../../commons/headers/common-headers';
import { {{MONGO_DOMAIN_ENTITY_PASCAL}} } from '{{MONGO_DOMAIN_ENTITY_IMPORT}}';
import type { {{MONGO_SCHEMA_PASCAL}} } from '../../../persistence/schemas/{{ENTITY_KEBAB}}.schema';

@Injectable()
export class SetDataMapper {
  private static readonly EMPTY_VALUE = '';

  request(data: {{MONGO_DOMAIN_ENTITY_PASCAL}}): Record<string, unknown> {
    return {
      type: (data as { type: string }).type,
    };
  }

  url(_: {{MONGO_DOMAIN_ENTITY_PASCAL}}): string {
    return '/{{ROUTE_PATH}}';
  }

  headers(
    data: {{MONGO_DOMAIN_ENTITY_PASCAL}},
    processId: string,
    req: Request,
  ): Record<string, string> {
    const commonHeaders = new CommonHeaders().get(req);
    const invokerUser = `${(data as { documentType: string }).documentType}${(data as { documentNumber: string }).documentNumber}`;

    return {
      ...commonHeaders,
      'X-Invoker-ProcessId': processId,
      'X-Invoker-TxId': processId,
      'X-Invoker-User': invokerUser,
      'X-Invoker-RequestNumber': `1-${invokerUser}`,
      'X-Invoker-TerminalId': SetDataMapper.EMPTY_VALUE,
    };
  }

  mapMongoToEntity(doc: {{MONGO_SCHEMA_PASCAL}}): {{MONGO_DOMAIN_ENTITY_PASCAL}} {
    const entity = doc as unknown as {{MONGO_DOMAIN_ENTITY_PASCAL}} & {
      id?: string;
      createdAt?: Date;
      updatedAt?: Date;
    };

    return {
      ...(entity as {{MONGO_DOMAIN_ENTITY_PASCAL}}),
      id: entity.id ?? '',
      createdAt: entity.createdAt ?? new Date(),
      updatedAt: entity.updatedAt ?? new Date(),
    } as {{MONGO_DOMAIN_ENTITY_PASCAL}};
  }
}
