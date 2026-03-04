import { SetDataMapper } from './set-data.mapper';

describe('SetDataMapper', () => {
  let mapper: SetDataMapper;

  beforeEach(() => {
    mapper = new SetDataMapper();
  });

  it('builds outbound request payload', () => {
    const result = mapper.request('CDT');
    expect(result).toEqual({ type: 'CDT' });
  });

  it('builds url for outbound validation', () => {
    expect(mapper.url()).toBe('/core/product-types/validate');
  });

  it('builds headers with common metadata', () => {
    const req = { headers: { 'user-agent': 'jest', host: 'localhost' } } as any;
    const headers = mapper.headers(
      { documentType: 'CC', documentNumber: '123' } as any,
      'trk-1',
      req,
    );
    expect(headers).toEqual(expect.objectContaining({ 'X-Invoker-ProcessId': 'trk-1' }));
    expect(headers['X-Invoker-User']).toBe('CC123');
    expect(headers['X-Invoker-RequestNumber']).toBe('1-CC123');
  });
});
