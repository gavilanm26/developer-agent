import { HttpService } from '@nestjs/axios';
import { of } from 'rxjs';
import { MsIdentityConfigAdapter } from './ms-identity-config.adapter';

describe('MsUserValidationAdapter', () => {
  let httpService: HttpService;
  let msUserValidationAdapter: MsIdentityConfigAdapter;

  beforeEach(() => {
    process.env.URLIDENTITYMANAGEMENT = 'http://localhost:3000';
    httpService = new HttpService();
    msUserValidationAdapter = new MsIdentityConfigAdapter(httpService);
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
