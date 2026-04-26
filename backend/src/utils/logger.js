const winston = require('winston');
const fs = require('fs');
const path = require('path');

const isProduction = process.env.NODE_ENV === 'production';
const isServerless =
  process.env.VERCEL === '1' || !!process.env.AWS_LAMBDA_FUNCTION_NAME;
let logDir = path.join(__dirname, '../../logs');
let enableFileLogging = !isProduction && !isServerless;

if (enableFileLogging && !fs.existsSync(logDir)) {
  try {
    fs.mkdirSync(logDir, { recursive: true });
  } catch (error) {
    enableFileLogging = false;
  }
}

const logFormat = winston.format.printf(({ timestamp, level, message, stack }) => {
  return stack
    ? `${timestamp} [${level}]: ${message} - ${stack}`
    : `${timestamp} [${level}]: ${message}`;
});

const transports = [
  new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
      logFormat
    ),
  }),
];

if (enableFileLogging) {
  transports.push(
    new winston.transports.File({
      filename: path.join(logDir, 'error.log'),
      level: 'error',
      format: winston.format.combine(
        winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
        logFormat
      ),
    }),

    new winston.transports.File({
      filename: path.join(logDir, 'combined.log'),
      format: winston.format.combine(
        winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
        logFormat
      ),
    })
  );
}

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'http',
  format: winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' })
  ),
  transports,
});

logger.http = (req, res, duration) => {
  const method = req.method;
  const url = req.originalUrl;
  const status = res.statusCode;
  const ip = req.ip;
  const log = `[${method}] ${url} - ${status} - ${duration}ms - IP: ${ip}`;

  logger.log({
    level: 'http',
    message: log,
  });
};

module.exports = logger;
