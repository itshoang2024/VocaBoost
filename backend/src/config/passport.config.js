const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const userModel = require('../models/user.model');
const validator = require('validator');
const logger = require('../utils/logger');

const requiredGoogleEnv = [
  'GOOGLE_CLIENT_ID',
  'GOOGLE_CLIENT_SECRET',
  'GOOGLE_CALLBACK_URL',
];

const missingGoogleEnv = requiredGoogleEnv.filter((key) => !process.env[key]);
const isGoogleOAuthConfigured = missingGoogleEnv.length === 0;

passport.serializeUser((user, done) => {
  done(null, user);
});

passport.deserializeUser((user, done) => {
  done(null, user);
});

if (isGoogleOAuthConfigured) {
  passport.use(
    new GoogleStrategy(
      {
        clientID: process.env.GOOGLE_CLIENT_ID,
        clientSecret: process.env.GOOGLE_CLIENT_SECRET,
        callbackURL: process.env.GOOGLE_CALLBACK_URL,
      },
      async (accessToken, refreshToken, profile, done) => {
        try {
          const email = validator.normalizeEmail(profile.emails[0].value);
          const googleId = profile.id;
          const displayName = profile.displayName;
          const avatarUrl = profile.photos[0]?.value;

          let user = await userModel.findByEmail(email);
          let isNewUser = false;

          if (user) {
            // Existing user - update Google info if missing
            if (!user.google_id)
              user = await userModel.updateGoogleId(user.id, googleId);
            if (!user.display_name)
              user = await userModel.updateDisplayName(user.id, displayName);
            if (!user.avatar_url)
              user = await userModel.updateAvatar(user.id, avatarUrl);
          } else {
            // New user - create account
            isNewUser = true;
            user = await userModel.createGoogleUser({
              email,
              googleId,
              displayName,
              avatarUrl,
              role: 'learner',
            });
          }

          return done(null, {
            id: user.id,
            email: user.email,
            role: user.role,
            displayName: user.display_name,
            avatarUrl: user.avatar_url,
            isNewUser: isNewUser,
          });
        } catch (error) {
          logger.error('Google OAuth Error:', error);
          return done(error, null);
        }
      }
    )
  );
} else {
  logger.warn(
    `Google OAuth disabled. Missing env vars: ${missingGoogleEnv.join(', ')}`
  );
}

module.exports = {
  isGoogleOAuthConfigured,
  missingGoogleEnv,
};
