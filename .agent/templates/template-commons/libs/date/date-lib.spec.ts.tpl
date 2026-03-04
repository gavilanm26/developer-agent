import { DateLib } from './date-lib';

describe('DateLib', () => {
  let dateLib: DateLib;

  beforeEach(() => {
    dateLib = new DateLib();
  });

  describe('getCurrentDate', () => {
    it('You must return the current date in Yyyy-Mm-DD format', () => {
      const currentDate = new Date();
      const year = currentDate.getFullYear();
      const month = String(currentDate.getMonth() + 1).padStart(2, '0');
      const day = String(currentDate.getDate()).padStart(2, '0');
      const expectedDate = `${year}-${month}-${day}`;

      expect(dateLib.getCurrentDate()).toBe(expectedDate);
    });
  });

  describe('getBogotaDate', () => {
    it('You must return the date in YyymmddD format for the time zone of Bogotá', () => {
      const result = dateLib.getBogotaDate();

      expect(typeof result).toBe('string');
      expect(result).toMatch(/^\d{4}\/\d{2}\/\d{2}$/);
    });
  });

  describe('getBogotaTimeIn24Hours', () => {
    it('You must return the time in 24 -hour format (HH: mm: ss) for Bogotá', () => {
      const result = dateLib.getBogotaTimeIn24Hours();

      expect(typeof result).toBe('string');
      expect(result).toMatch(/^\d{2}:\d{2}:\d{2}$/);
    });

    it('should format single digit hours, minutes and seconds with leading zeros', () => {
      const mockDate = new Date('2024-01-01T09:05:03.123Z');
      jest.spyOn(global, 'Date').mockImplementation(() => mockDate);

      const result = dateLib.getBogotaTimeIn24Hours();

      expect(result).toMatch(/^\d{2}:\d{2}:\d{2}$/);
      const utc = mockDate.getTime() + mockDate.getTimezoneOffset() * 60000;
      const bogotaTime = new Date(utc + 3600000 * -5);
      const hours = bogotaTime.getHours();
      const minutes = bogotaTime.getMinutes();
      const seconds = bogotaTime.getSeconds();
      const formattedHours = hours < 10 ? `0${hours}` : hours;
      const formattedMinutes = minutes < 10 ? `0${minutes}` : minutes;
      const formattedSeconds = seconds < 10 ? `0${seconds}` : seconds;
      const expectedTime = `${formattedHours}:${formattedMinutes}:${formattedSeconds}`;

      expect(result).toBe(expectedTime);

      jest.restoreAllMocks();
    });

    it('should format double digit hours, minutes and seconds without leading zeros', () => {
      const mockDate = new Date('2024-01-01T15:25:43.123Z');
      jest.spyOn(global, 'Date').mockImplementation(() => mockDate);

      const result = dateLib.getBogotaTimeIn24Hours();

      expect(result).toMatch(/^\d{2}:\d{2}:\d{2}$/);
      const utc = mockDate.getTime() + mockDate.getTimezoneOffset() * 60000;
      const bogotaTime = new Date(utc + 3600000 * -5);
      const hours = bogotaTime.getHours();
      const minutes = bogotaTime.getMinutes();
      const seconds = bogotaTime.getSeconds();
      const formattedHours = hours < 10 ? `0${hours}` : hours;
      const formattedMinutes = minutes < 10 ? `0${minutes}` : minutes;
      const formattedSeconds = seconds < 10 ? `0${seconds}` : seconds;
      const expectedTime = `${formattedHours}:${formattedMinutes}:${formattedSeconds}`;

      expect(result).toBe(expectedTime);

      jest.restoreAllMocks();
    });
  });

  describe('getBogotaDateTimeWithMilliseconds', () => {
    it('You must return date and time in ISO format with milliseconds', () => {
      const result = dateLib.getBogotaDateTimeWithMilliseconds();

      expect(typeof result).toBe('string');
      expect(result).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}$/);
    });
  });
});
