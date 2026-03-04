import { Injectable } from '@nestjs/common';
import { Request } from 'express';

import { CommonHeaders } from '@commons/headers/common-headers';
import { ValidateOtcPayloadModel } from '../../../../domain/models/validate-otc-payload.model';

@Injectable()
export class ValidateOtcMapper {
  private readonly idOtc = '0004';

  request(data: ValidateOtcPayloadModel) {
    return {
      govIssueIdent: {
        govIssueIdentType: data.documentType,
        identSerialNum: data.documentNumber,
      },
      otc: {
        idOtc: this.idOtc,
        otcCode: data.code,
      },
      contactInfo: {
        emailAddr: data.email,
        phoneNum: {
          phone: data.cellPhone,
        },
      },
    };
  }

  url(): string {
    return '/validateOTC';
  }

  headers(
    data: Pick<ValidateOtcPayloadModel, 'documentType' | 'documentNumber'>,
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
