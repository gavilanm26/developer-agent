import { Injectable } from '@nestjs/common';
import { CommonHeaders } from '@commons/headers/common-headers';
import { AuthRequest } from '../../../../domain/models/auth-request.model';
import CryptoCore from '@commons/libs/crypto/crypto-core';
import { Request } from 'express';

@Injectable()
export class SetDataMapper {
  request(data: AuthRequest) {
    return {
      engineRiskInfo: {
        transactionId: this.generateTransactionId(),
      },
      govIssueIdent: {
        identSerialNum: data.documentNumber,
        govIssueIdentType: data.documentType,
      },
      personInfo: {
        nameAddrType: 'N',
      },
      custId: {
        SPName: data.documentNumber,
      },
      custPswd: {
        pswd: CryptoCore.encrypt(data.password),
      },
    };
  }

  headers(
    data: AuthRequest,
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
      grant_type: 'CLIENT_CREDENTIALS',
      client_id: process.env.APIAUTHCLIENTID,
      client_secret: process.env.APIAUTHCLIENTSECRET,
      authorization: `Bearer ${tokenCore.access_token}`,
    };
  }

  generateTransactionId(): string {
    const array = new Uint32Array(1);
    crypto.getRandomValues(array);
    const value = array[0];

    return value.toString();
  }
}
