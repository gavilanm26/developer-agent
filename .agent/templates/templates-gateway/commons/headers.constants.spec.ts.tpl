import { requiredHeaders } from './headers.constants';

describe('requiredHeaders', () => {
  it('should contain the expected headers', () => {
    const expectedHeaders = ['X-Tracking-Op'];
    expect(requiredHeaders).toEqual(expectedHeaders);
  });
});
