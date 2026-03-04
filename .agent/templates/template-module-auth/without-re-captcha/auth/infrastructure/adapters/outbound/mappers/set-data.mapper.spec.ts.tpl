import { Test } from '@nestjs/testing';
import { CommonHeaders } from '@commons/headers/common-headers';
import { SetDataMapper } from '@modules/auth/infrastructure/adapters/outbound/mappers/set-data.mapper';
import CryptoCore from '@commons/libs/crypto/crypto-core';
import { TypeOfDocuments } from '@commons/enums/type-of-documents.enum';

describe('SetDataMapper', () => {
  let setDataServices: SetDataMapper;
  let processId: string;
  let tokenCore: { access_token: string };

  interface DataType {
    documentNumber: string;
    documentType: TypeOfDocuments;
    password: string;
    tokenRecaptcha: string;
  }

  let data: DataType;

  beforeEach(async () => {
    process.env = Object.assign(process.env, {
      APIAUTHCLIENTID: 'testClientId',
      APIAUTHCLIENTSECRET: 'testClientSecret',
      INFRAENCRYPTKEYCORE: 'testEncryptKeyCore',
      TRANSACTIONID: '1',
    });

    const moduleRef = await Test.createTestingModule({
      providers: [SetDataMapper],
    }).compile();

    setDataServices = moduleRef.get<SetDataMapper>(SetDataMapper);
    processId = 'testProcessId';
    tokenCore = { access_token: 'testAccessToken' };

    data = {
      documentNumber: '123456',
      documentType: 'CC' as any,
      password: 'password',
      tokenRecaptcha: 'testToken',
    };

    jest.spyOn(CryptoCore, 'encrypt').mockReturnValue('encryptedPassword');

    // Mock para crypto.getRandomValues
    global.crypto = {
      getRandomValues: (arr: Uint32Array) => {
        arr[0] = 123456; // Valor fijo para asegurar consistencia en los tests
        return arr;
      },
    } as Crypto;
  });

  it('should return a valid request object', () => {
    const result = setDataServices.request(data);

    expect(result.engineRiskInfo.transactionId).toBeDefined();
    expect(result.govIssueIdent.identSerialNum).toBe(data.documentNumber);
    expect(result.govIssueIdent.govIssueIdentType).toBe(data.documentType);
    expect(result.personInfo.nameAddrType).toBe('N');
    expect(result.custPswd.pswd).toBe('encryptedPassword');

    expect(CryptoCore.encrypt).toHaveBeenCalledWith(data.password);
  });

  it('should return a valid header object', () => {
    const commonHeaders = new CommonHeaders().get({ headers: {} } as any);
    const mockRequest = { headers: {} };
    const result = setDataServices.headers(
      data,
      processId,
      tokenCore,
      mockRequest as any,
    );

    expect(result).toEqual(
      expect.objectContaining({
        ...commonHeaders,
        'X-Invoker-ProcessId': processId,
        'X-Invoker-TxId': processId,
        'X-Invoker-User': `${data.documentType}${data.documentNumber}`,
        'X-Invoker-RequestNumber': `1-${data.documentType}${data.documentNumber}`,
        'X-StartDt': expect.any(String),
        client_id: 'testClientId',
        client_secret: 'testClientSecret',
        grant_type: 'CLIENT_CREDENTIALS',
        authorization: `Bearer ${tokenCore.access_token}`,
      }),
    );
  });

  it('should return a valid transaction id', () => {
    const result = setDataServices.generateTransactionId();
    expect(result).toBe('123456');
  });
});
