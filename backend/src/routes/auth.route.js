const express = require('express');
const authRouter = express.Router();
const passport = require('passport');

const authValidators = require('../validators/auth.validator');
const authController = require('../controllers/auth.controller');
const authenticateMiddleware = require('../middlewares/authenticate.middleware');
const ResponseUtils = require('../utils/response');
const { isGoogleOAuthConfigured } = require('../config/passport.config');

const googleOAuthUnavailable = (req, res) => {
  if (process.env.FRONTEND_URL) {
    return res.redirect(
      `${process.env.FRONTEND_URL}/login?error=oauth_unconfigured`
    );
  }

  return ResponseUtils.error(res, 'Google OAuth is not configured', 503);
};

// Registration & Login & Logout
authRouter.post('/register', authValidators.register, authController.register);

authRouter.post('/login', authValidators.login, authController.login);

authRouter.post('/logout', authController.logout);

// Token Refresh
authRouter.post('/refresh-token', authController.refreshToken);

// OAuth Routes
authRouter.get(
  '/google',
  isGoogleOAuthConfigured
    ? passport.authenticate('google', {
        scope: ['profile', 'email'],
        session: false,
        prompt: 'select_account', // Force account selection
      })
    : googleOAuthUnavailable
);

authRouter.get(
  '/google/callback',
  isGoogleOAuthConfigured ? authController.googleCallback : googleOAuthUnavailable
);

// Password Reset Flow
authRouter.post(
  '/forgot-password',
  authValidators.email,
  authController.forgotPassword
);

authRouter.post(
  '/reset-password',
  authValidators.resetPassword,
  authController.resetPassword
);

authRouter.get('/verify-email/:token', authController.verifyEmail);

authRouter.post(
  '/resend-verification',
  authValidators.email,
  authController.resendVerification
);

authRouter.post(
  '/get-account-status',
  authValidators.email,
  authController.getAccountStatus
);

authRouter.get(
  '/validate-token',
  authenticateMiddleware,
  authController.validateToken
);

module.exports = authRouter;
