import { SiteConfigServiceImpl } from './site-config.service.impl';
import { ConfigSiteAdapter } from '../domain/config-site.adapter';
import { ResponseDto } from '../../../dto/response';
import { RequestDto } from '../../../dto/request';

describe('GetRateService', () => {
  let UserVal: SiteConfigServiceImpl;
  let userValidationAdapter: ConfigSiteAdapter;

  beforeEach(() => {
    userValidationAdapter = {} as ConfigSiteAdapter;
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
