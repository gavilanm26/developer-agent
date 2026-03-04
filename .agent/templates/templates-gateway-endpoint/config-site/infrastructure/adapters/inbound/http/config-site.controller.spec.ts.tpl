import { ConfigSiteUsecase } from '../../../../application/ports/config-site.usecase';
import { ResponseDto } from '@app/dto/response';
import { ConfigSiteController } from './config-site.controller';

describe('UserValidationController', () => {
  let userValidationService: ConfigSiteUsecase;
  let userValidationController: ConfigSiteController;

  beforeEach(() => {
    userValidationService = {
      get: jest.fn(),
    } as any;
    userValidationController = new ConfigSiteController(userValidationService);
  });

  describe('post', () => {
    it('should call userValidationService.get and return the result', async () => {
      const requestBody = { data: '' };

      const expectedResult: ResponseDto = { response: 'ok' };

      jest
        .spyOn(userValidationService, 'get')
        .mockResolvedValue(expectedResult);

      const result = await userValidationController.get(requestBody);

      // eslint-disable-next-line @typescript-eslint/unbound-method
      expect(userValidationService.get).toHaveBeenCalledWith(requestBody);
      expect(result).toBe(expectedResult);
    });
  });
});
