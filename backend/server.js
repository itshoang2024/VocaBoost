const path = require('path');

require('dotenv').config({ path: path.resolve(__dirname, '.env') });
const logger = require('./src/utils/logger');
const { scheduleCleanup } = require('./src/utils/tokenCleanup');
const PORT = process.env.PORT || 3000;

const app = require('./src/app');

// Start the server
app.listen(PORT, () => {
  logger.info(`URL of app: http://127.0.0.1:${PORT}/`);

  // Schedule token blacklist cleanup (runs every 24 hours)
  scheduleCleanup(24);
});
