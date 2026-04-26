describe('passport config', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    jest.resetModules();
    process.env = { ...originalEnv, NODE_ENV: 'test' };

    delete process.env.GOOGLE_CLIENT_ID;
    delete process.env.GOOGLE_CLIENT_SECRET;
    delete process.env.GOOGLE_CALLBACK_URL;

    jest.doMock('../../src/models/user.model', () => ({}));
    jest.doMock('../../src/utils/logger', () => ({
      error: jest.fn(),
      warn: jest.fn(),
    }));
  });

  afterEach(() => {
    process.env = originalEnv;
    jest.dontMock('../../src/models/user.model');
    jest.dontMock('../../src/utils/logger');
  });

  it('does not throw when Google OAuth env vars are missing', () => {
    expect(() => require('../../src/config/passport.config')).not.toThrow();

    const config = require('../../src/config/passport.config');
    const logger = require('../../src/utils/logger');

    expect(config.isGoogleOAuthConfigured).toBe(false);
    expect(config.missingGoogleEnv).toEqual([
      'GOOGLE_CLIENT_ID',
      'GOOGLE_CLIENT_SECRET',
      'GOOGLE_CALLBACK_URL',
    ]);
    expect(logger.warn).toHaveBeenCalledWith(
      expect.stringContaining('Google OAuth disabled')
    );
  });
});
