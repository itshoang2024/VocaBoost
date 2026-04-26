describe('logger', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    jest.resetModules();
    process.env = { ...originalEnv };
  });

  afterEach(() => {
    process.env = originalEnv;
  });

  it('uses console-only logging in Vercel serverless runtime', () => {
    process.env.VERCEL = '1';
    delete process.env.NODE_ENV;

    const logger = require('../../src/utils/logger');

    expect(logger.transports).toHaveLength(1);
    expect(logger.transports[0].constructor.name).toBe('Console');
  });
});
