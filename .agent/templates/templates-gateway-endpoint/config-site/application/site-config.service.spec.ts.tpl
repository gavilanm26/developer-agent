import { SiteConfigServiceImpl } from './site-config.service.impl';
import { ConfigSiteClientPort } from '../domain/ports/config-site.client.port';
import { ResponseDto } from '@app/dto/response';
import { RequestDto } from '@app/dto/request';

describe('GetRateService', () => {
  let UserVal: SiteConfigServiceImpl;
  let userValidationAdapter: ConfigSiteClientPort;

  beforeEach(() => {
    userValidationAdapter = {} as ConfigSiteClientPort;
    UserVal = new SiteConfigServiceImpl(userValidationAdapter);
  });

  it('should call userValidationAdapter.get with the RequestDto', async () => {
    const generateResponseDto: ResponseDto = {
      response: 'string',
    } as ResponseDto;

    const requestDto: RequestDto = { data: 'data requestDto' };
    userValidationAdapter.get = jest
      .fn()
      .mockResolvedValue(generateResponseDto);
    const result = await UserVal.get(requestDto);
    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(userValidationAdapter.get).toBeDefined();
    expect(result).toBe(generateResponseDto);
  });
});
