const logger = require('./logger');
const ResponseUtils = require('./response');

class ErrorHandler {
  static asyncHandler(fn) {
    return (req, res, next) => {
      Promise.resolve(fn(req, res, next)).catch(next);
    };
  }

  static handleError(
    res,
    error,
    context,
    userMessage = 'Operation failed',
    statusCode = 500
  ) {
    logger.error(`[${context}] Error:`, error);

    const responseStatusCode = error.statusCode || statusCode;
    const details = error.publicDetails || null;

    if (error.retryAfterSeconds && typeof res.set === 'function') {
      res.set('Retry-After', String(error.retryAfterSeconds));
    }

    // Don't expose internal error details in production
    const message =
      process.env.NODE_ENV === 'production'
        ? error.userMessage || userMessage
        : error.message || userMessage;

    return ResponseUtils.error(res, message, responseStatusCode, details);
  }

  static handleDatabaseError(res, error, operation, resource) {
    const context = `Database ${operation} - ${resource}`;
    const userMessage = `Failed to ${operation.toLowerCase()} ${resource.toLowerCase()}`;

    return this.handleError(res, error, context, userMessage, 500);
  }

  static handleValidationError(res, error, context) {
    logger.error(`[${context}] Validation error:`, error);
    return ResponseUtils.validationError(res, error.message || 'Validation failed');
  }

  static handleAuthError(res, error, context) {
    logger.error(`[${context}] Authentication error:`, error);
    return ResponseUtils.unauthorized(res, 'Invalid credentials');
  }

  static handleAuthorizationError(res, error, context) {
    logger.error(`[${context}] Authorization error:`, error);
    return ResponseUtils.forbidden(res, 'Access denied');
  }

  static handleNotFoundError(res, resource) {
    return ResponseUtils.notFound(res, `${resource} not found`);
  }

  static handleDuplicateError(res, resource) {
    return ResponseUtils.conflict(res, `${resource} already exists`);
  }
}

module.exports = ErrorHandler;
