import { Injectable } from '@nestjs/common';
import { Request } from 'express';

import { CommonHeaders } from '@commons/headers/common-headers';
import { GenerateOtcPayloadModel } from '../../../../domain/models/generate-otc-payload.model';

@Injectable()
export class GenerateOtcMapper {
  url(): string {
    return '/generateOTC';
  }

  request(data: GenerateOtcPayloadModel) {
    return {
      govIssueIdent: {
        govIssueIdentType: data.documentType,
        identSerialNum: data.documentNumber,
      },
      otc: {
        idOtc: '0001',
        otcReason: {
          listParams: [
            {
              password: `${process.env.APPTXTOTCTRANSACTION}`,
              value: data.transactionName,
            },
          ],
        },
      },
      otcIssue: {
        listParams: [
          {
            password: `${process.env.APPTXOTCTPROCESS}`,
            value: 'Código de seguridad',
          },
        ],
      },
      contactInfo: {
        emailAddr: data.email,
        phoneNum: {
          phone: data.cellPhone,
        },
      },
    };
  }

  headers(
    data: Pick<GenerateOtcPayloadModel, 'documentType' | 'documentNumber'>,
    processId: string,
    tokenCore: { access_token: string },
    req: Request,
  ) {
    const commonHeaders = new CommonHeaders().get(req);

    return {
      ...commonHeaders,
      'X-Invoker-ProcessId': processId,
      'X-Invoker-TxId': processId,
      'X-Invoker-User': data.documentType + data.documentNumber,
      'X-Invoker-RequestNumber': `1-${data.documentType}${data.documentNumber}`,
      'X-Invoker-TerminalId': '',
      client_id: process.env.APISECURITYMANAGEMENTCLIENTID,
      client_secret: process.env.APISECURITYMANAGEMENTSECRET,
      authorization: `Bearer ${tokenCore.access_token}`,
    };
  }
}
