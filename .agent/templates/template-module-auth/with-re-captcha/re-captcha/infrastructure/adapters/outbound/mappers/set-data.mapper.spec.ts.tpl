import { SetDataMapper } from '@modules/re-captcha/infrastructure/adapters/outbound/mappers/set-data.mapper';

describe('SetDataMapper', () => {
  let setDataServices;

  beforeEach(() => {
    setDataServices = new SetDataMapper();
  });

  describe('queryString', () => {
    it('should return the correct URL', () => {
      const expectedURL = `?secret=${process.env.INFRARECAPTCHASECRETKEY}&response=BCS`;

      const result = setDataServices.queryString('BCS');

      expect(result).toEqual(expectedURL);
    });
  });
});
