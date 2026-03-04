import { HttpService } from '@nestjs/axios';
import { of } from 'rxjs';
import { MsIdentityConfigRestClient } from './ms-identity-config.rest.client';

describe('MsIdentityConfigRestClient', () => {
  let httpService: HttpService;
  let msUserValidationAdapter: MsIdentityConfigRestClient;

  beforeEach(() => {
    process.env.APIURLIDENTITYMANAGEMENT = 'http://localhost:3000';
    httpService = new HttpService();
    msUserValidationAdapter = new MsIdentityConfigRestClient(httpService);
  });

  it('should retrieve response data from the API', async () => {
    const responseData = { response: { documentNumber: '1234' } };

    const response = of({
      data: responseData,
      status: 200,
      statusText: 'OK',
      headers: { 'X-Tracking-Op': 'uvalidation' },
      config: {} as any,
    });

    jest.spyOn(httpService, 'post').mockReturnValue(response);

    const result = await msUserValidationAdapter.get(responseData);

    expect(result).toEqual(responseData);
  });
});
