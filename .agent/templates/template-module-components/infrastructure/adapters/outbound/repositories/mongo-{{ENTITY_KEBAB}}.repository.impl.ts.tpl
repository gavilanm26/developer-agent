import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import type { Model } from 'mongoose';
import type { Request } from 'express';
import { firstValueFrom, from } from 'rxjs';
import { map } from 'rxjs/operators';

import { internalLogger } from '@commons/http-logger/httpLogger';
import { {{ENTITY_PASCAL}}RepositoryPort } from '../../../../domain/ports/{{ENTITY_KEBAB}}.repository.port';
import { {{MONGO_SCHEMA_PASCAL}} } from '../../../persistence/schemas/{{ENTITY_KEBAB}}.schema';
import { {{MONGO_FIND_FILTER_TYPE}} } from '../../../../domain/interfaces/{{ENTITY_KEBAB}}-filter.interface';
import { {{MONGO_DOMAIN_ENTITY_PASCAL}} } from '{{MONGO_DOMAIN_ENTITY_IMPORT}}';
import { SetDataMapper } from '../mappers/set-data.mapper';

@Injectable()
export class Mongo{{ENTITY_PASCAL}}RepositoryImpl implements {{ENTITY_PASCAL}}RepositoryPort {
  private readonly logger = new Logger(Mongo{{ENTITY_PASCAL}}RepositoryImpl.name);

  constructor(
    @InjectModel({{MONGO_SCHEMA_PASCAL}}.name)
    private readonly model: Model<{{MONGO_SCHEMA_PASCAL}}>,
    private readonly set: SetDataMapper,
  ) {}

  async findOne(
    filter: {{MONGO_FIND_FILTER_TYPE}},
    req?: Request,
  ): Promise<{{MONGO_DOMAIN_ENTITY_PASCAL}} | null> {
    const { processId, ...queryWithoutStatus } =
      filter as unknown as Record<string, unknown>;

    const filteredHeaders =
      req?.headers && typeof req.headers === 'object'
        ? Object.keys(req.headers).reduce((obj, key) => {
            if (key.toLowerCase().startsWith('x-')) {
              obj[key] = req.headers[key] as string;
            }
            return obj;
          }, {} as Record<string, string>)
        : undefined;

    const doc = await this.model.findOne(queryWithoutStatus as any).exec();

    if (!doc) {
      await firstValueFrom(
        from(Promise.resolve(null)).pipe(
          map((res) => ({ result: res })),
          internalLogger(
            this.logger,
            true,
            processId,
            null,
            { query: queryWithoutStatus },
            filteredHeaders,
            '{{MONGO_LOG_OPERATION}}',
          ),
        ),
      );
      return null;
    }

    const docWithStatus = doc as unknown as { status?: string };
    if (docWithStatus.status === 'INACTIVE') {
      await firstValueFrom(
        from(Promise.resolve(doc)).pipe(
          map((res) => ({ result: res })),
          internalLogger(
            this.logger,
            true,
            processId,
            null,
            { query: queryWithoutStatus, status: docWithStatus.status },
            filteredHeaders,
            '{{MONGO_LOG_OPERATION}}',
          ),
        ),
      );
      throw new NotFoundException('{{ENTITY_PASCAL}} inactive');
    }

    const result = await firstValueFrom(
      from(Promise.resolve(doc)).pipe(
        map((res) => ({ result: res })),
        internalLogger(
          this.logger,
          true,
          processId,
          null,
          { query: queryWithoutStatus },
          filteredHeaders,
          '{{MONGO_LOG_OPERATION}}',
        ),
      ),
    );

    return this.set.mapMongoToEntity(result) as {{MONGO_DOMAIN_ENTITY_PASCAL}};
  }
}
