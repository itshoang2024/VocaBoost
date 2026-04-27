const { GoogleGenAI } = require('@google/genai');
const logger = require('../utils/logger');

class AIServiceError extends Error {
  constructor(message, options = {}) {
    super(message);
    this.name = 'AIServiceError';
    this.isAIServiceError = true;
    this.statusCode = options.statusCode || 500;
    this.code = options.code || 'AI_SERVICE_ERROR';
    this.retryable = options.retryable || false;
    this.retryAfterSeconds = options.retryAfterSeconds || null;
    this.userMessage = message;
    this.cause = options.cause;
    this.publicDetails = {
      code: this.code,
      ...(this.retryAfterSeconds
        ? { retryAfterSeconds: this.retryAfterSeconds }
        : {}),
    };
  }
}

class AIService {
  constructor() {
    this.genAI = null;
    this.model = null;
    this.initializeAI();
  }

  initializeAI() {
    this.model =
      process.env.GEMINI_MODEL ||
      process.env.MODEL_ID ||
      'gemini-3.1-flash-lite-preview';

    if (!process.env.GEMINI_API_KEY) {
      logger.warn('Google Gemini AI is not configured: missing GEMINI_API_KEY');
      this.genAI = null;
      return;
    }

    try {
      this.genAI = new GoogleGenAI({
        apiKey: process.env.GEMINI_API_KEY,
        model: this.model,
      });
      // Add a small delay between requests to avoid rate limiting
      this.lastRequestTime = 0;
      this.minRequestInterval = 500; // 500ms between requests
      logger.info(`Google Gemini AI initialized with model: ${this.model}`);
    } catch (error) {
      logger.error('Failed to initialize Google Gemini AI:', error);
      this.genAI = null;
    }
  }

  isAvailable() {
    return this.genAI !== null;
  }

  async generateExample(word, definition, context = null) {
    if (!this.genAI) {
      throw this._createUnavailableError();
    }

    const maxRetries = 3;
    const retryDelay = 1000; // Start with 1 second

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Rate limiting to prevent too many rapid requests
        const now = Date.now();
        const timeSinceLastRequest = now - this.lastRequestTime;
        if (timeSinceLastRequest < this.minRequestInterval) {
          await new Promise((resolve) =>
            setTimeout(resolve, this.minRequestInterval - timeSinceLastRequest)
          );
        }

        const prompt = this._buildExamplePrompt(word, definition, context);

        const response = await this.genAI.models.generateContent({
          model: this.model,
          contents: prompt,
        });
        const example = response.text;

        logger.info(`Generated example for word: ${word}`);
        this.lastRequestTime = Date.now();
        return example;
      } catch (error) {
        const aiError = this._normalizeGenerationError(error);

        if (aiError.retryable && attempt < maxRetries) {
          const waitTime = retryDelay * attempt;
          logger.warn(
            `AI model overloaded, retrying in ${waitTime}ms (attempt ${attempt}/${maxRetries})`
          );
          await new Promise((resolve) => setTimeout(resolve, waitTime));
          continue;
        }

        logger.error(
          `Failed to generate example (attempt ${attempt}/${maxRetries}):`,
          error
        );

        throw aiError;
      }
    }
  }

  async generateMissingFields(word, definition, currentData = {}, context = null) {
    if (!this.genAI) {
      throw this._createUnavailableError();
    }

    const maxRetries = 3;
    const retryDelay = 1000; // Start with 1 second

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Rate limiting to prevent too many rapid requests
        const now = Date.now();
        const timeSinceLastRequest = now - this.lastRequestTime;
        if (timeSinceLastRequest < this.minRequestInterval) {
          await new Promise((resolve) =>
            setTimeout(resolve, this.minRequestInterval - timeSinceLastRequest)
          );
        }

        const prompt = this._buildMissingFieldsPrompt(
          word,
          definition,
          currentData,
          context
        );
        // console.log('🔍 Missing fields being detected:', this._detectMissingFields(currentData));
        // console.log('📤 AI Prompt:', prompt);

        const response = await this.genAI.models.generateContent({
          model: this.model,
          contents: prompt,
        });

        const generatedText = response.text;
        // console.log('📥 Raw AI Response:', generatedText);

        const parsedResult = this._parseMissingFieldsResponse(generatedText);
        // console.log('✅ Parsed AI Result:', parsedResult);

        logger.info(`Generated missing fields for word: ${word}`);
        this.lastRequestTime = Date.now();
        return parsedResult;
      } catch (error) {
        const aiError = this._normalizeGenerationError(error);

        if (aiError.retryable && attempt < maxRetries) {
          const waitTime = retryDelay * attempt;
          logger.warn(
            `AI model overloaded, retrying in ${waitTime}ms (attempt ${attempt}/${maxRetries})`
          );
          await new Promise((resolve) => setTimeout(resolve, waitTime));
          continue;
        }

        logger.error(
          `Failed to generate missing fields (attempt ${attempt}/${maxRetries}):`,
          error
        );

        throw aiError;
      }
    }
  }

  _buildExamplePrompt(word, definition, context) {
    let prompt = `Generate a clear, natural example sentence using the word "${word}" (definition: ${definition}).`;

    if (context) {
      prompt += ` The sentence should be in the context of ${context}.`;
    }

    prompt += ` Requirements:
    - The sentence should clearly demonstrate the meaning of the word
    - Use simple, everyday language
    - Make it memorable and practical
    - The sentence should be between 10-20 words
    - Only return the example sentence, nothing else`;

    return prompt;
  }

  _buildMissingFieldsPrompt(word, definition, currentData, context) {
    const missingFields = this._detectMissingFields(currentData);

    if (missingFields.length === 0) {
      throw new Error('No missing fields to generate');
    }

    let prompt = `For the English word "${word}" (definition: ${definition}), please generate the following missing fields:\n\n`;

    if (missingFields.includes('phonetics')) {
      prompt += `- Phonetics: Provide the IPA phonetic transcription (e.g., /ˈhæpi/ for "happy")\n`;
    }
    if (missingFields.includes('synonyms')) {
      prompt += `- Synonyms: Provide 2-4 common synonyms separated by commas\n`;
    }
    if (missingFields.includes('translation')) {
      prompt += `- Translation: Provide the Vietnamese translation\n`;
    }
    if (missingFields.includes('exampleSentence')) {
      prompt += `- Example Sentence: Provide a clear, natural example sentence (10-20 words)\n`;
    }

    if (context) {
      prompt += `\nContext: ${context}\n`;
    }

    prompt += `\nFormat your response as JSON:
{
  ${missingFields.includes('phonetics') ? '"phonetics": "/phonetic-transcription/",' : ''}
  ${missingFields.includes('synonyms') ? '"synonyms": ["synonym1", "synonym2", "synonym3"],' : ''}
  ${missingFields.includes('translation') ? '"translation": "Vietnamese translation",' : ''}
  ${missingFields.includes('exampleSentence') ? '"exampleSentence": "Example sentence using the word"' : ''}
}

Only include the fields that are missing. Return only valid JSON, no additional text.`;

    return prompt;
  }

  _detectMissingFields(currentData) {
    const missingFields = [];

    console.log('🔍 Detecting missing fields from data:', currentData);

    if (!currentData.phonetics || currentData.phonetics.trim() === '') {
      console.log('❌ phonetics is missing:', currentData.phonetics);
      missingFields.push('phonetics');
    } else {
      console.log('✅ phonetics has value:', currentData.phonetics);
    }

    if (!currentData.synonyms || currentData.synonyms.length === 0) {
      console.log('❌ synonyms is missing:', currentData.synonyms);
      missingFields.push('synonyms');
    } else {
      console.log('✅ synonyms has value:', currentData.synonyms);
    }

    if (!currentData.translation || currentData.translation.trim() === '') {
      console.log('❌ translation is missing:', currentData.translation);
      missingFields.push('translation');
    } else {
      console.log('✅ translation has value:', currentData.translation);
    }

    if (!currentData.exampleSentence || currentData.exampleSentence.trim() === '') {
      console.log('❌ exampleSentence is missing:', currentData.exampleSentence);
      missingFields.push('exampleSentence');
    } else {
      console.log('✅ exampleSentence has value:', currentData.exampleSentence);
    }

    console.log('🎯 Final missing fields detected:', missingFields);
    return missingFields;
  }

  _createUnavailableError() {
    return new AIServiceError(
      'AI service is temporarily unavailable. Please check Gemini configuration.',
      {
        statusCode: 503,
        code: 'AI_UNAVAILABLE',
      }
    );
  }

  _normalizeGenerationError(error) {
    if (error?.isAIServiceError) {
      return error;
    }

    if (error?.message === 'No missing fields to generate') {
      return new AIServiceError('No missing fields to generate.', {
        statusCode: 400,
        code: 'AI_NO_MISSING_FIELDS',
        cause: error,
      });
    }

    if (this._isQuotaError(error)) {
      return new AIServiceError(
        'Gemini quota is exhausted for the configured model. Please check your Gemini quota or switch GEMINI_MODEL to a model with available quota.',
        {
          statusCode: 429,
          code: 'AI_QUOTA_EXHAUSTED',
          retryAfterSeconds: this._getRetryDelaySeconds(error),
          cause: error,
        }
      );
    }

    if (this._isOverloadedError(error)) {
      return new AIServiceError(
        'AI service is currently busy. Please try again in a few moments.',
        {
          statusCode: 503,
          code: 'AI_OVERLOADED',
          retryable: true,
          cause: error,
        }
      );
    }

    return new AIServiceError(
      'AI service could not generate content. Please try again later.',
      {
        statusCode: 502,
        code: 'AI_PROVIDER_ERROR',
        cause: error,
      }
    );
  }

  _isQuotaError(error) {
    const payload = this._extractProviderPayload(error);
    const message = this._getProviderMessage(error).toLowerCase();
    const status = payload?.status || error?.status;
    const code = payload?.code || error?.code;

    return (
      code === 429 ||
      status === 'RESOURCE_EXHAUSTED' ||
      message.includes('resource_exhausted') ||
      message.includes('quota exceeded') ||
      message.includes('rate limit')
    );
  }

  _isOverloadedError(error) {
    const payload = this._extractProviderPayload(error);
    const message = this._getProviderMessage(error).toLowerCase();
    const status = payload?.status || error?.status;
    const code = payload?.code || error?.code;

    return (
      code === 503 ||
      status === 'UNAVAILABLE' ||
      message.includes('overloaded') ||
      message.includes('temporarily unavailable')
    );
  }

  _getRetryDelaySeconds(error) {
    const payload = this._extractProviderPayload(error);
    const details = payload?.details || error?.details || [];
    const retryInfo = details.find((detail) => detail?.retryDelay);
    const retryDelay = retryInfo?.retryDelay;

    if (typeof retryDelay === 'string') {
      const seconds = Number.parseFloat(retryDelay.replace('s', ''));
      return Number.isFinite(seconds) ? Math.ceil(seconds) : null;
    }

    const messageMatch =
      this._getProviderMessage(error).match(/retry in ([\d.]+)s/i);
    if (messageMatch) {
      const seconds = Number.parseFloat(messageMatch[1]);
      return Number.isFinite(seconds) ? Math.ceil(seconds) : null;
    }

    return null;
  }

  _getProviderMessage(error) {
    const payload = this._extractProviderPayload(error);
    return payload?.message || error?.message || String(error || '');
  }

  _extractProviderPayload(error) {
    if (error?.error) {
      return error.error;
    }

    if (typeof error?.message !== 'string') {
      return null;
    }

    const trimmedMessage = error.message.trim();
    if (!trimmedMessage.startsWith('{')) {
      return null;
    }

    try {
      const parsed = JSON.parse(trimmedMessage);
      return parsed.error || parsed;
    } catch (_) {
      return null;
    }
  }

  _parseMissingFieldsResponse(responseText) {
    try {
      // Clean up the response text
      let cleanedText = responseText.trim();

      // Remove markdown code blocks if present
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.replace(/^```json\s*/, '').replace(/\s*```$/, '');
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.replace(/^```\s*/, '').replace(/\s*```$/, '');
      }

      // Parse JSON
      const parsed = JSON.parse(cleanedText);

      // Validate and clean the parsed data
      const result = {};
      const phonetics =
        parsed.phonetics || parsed.pronunciation || parsed.phonetic || parsed.ipa;
      const exampleSentence =
        parsed.exampleSentence || parsed.example || parsed.example_sentence;

      if (phonetics && typeof phonetics === 'string') {
        result.phonetics = phonetics.trim();
      }

      if (Array.isArray(parsed.synonyms)) {
        result.synonyms = parsed.synonyms
          .filter((s) => typeof s === 'string' && s.trim() !== '')
          .map((s) => s.trim());
      } else if (typeof parsed.synonyms === 'string') {
        result.synonyms = parsed.synonyms
          .split(',')
          .map((s) => s.trim())
          .filter(Boolean);
      }

      if (parsed.translation && typeof parsed.translation === 'string') {
        result.translation = parsed.translation.trim();
      }

      if (exampleSentence && typeof exampleSentence === 'string') {
        result.exampleSentence = exampleSentence.trim();
      }

      if (Object.keys(result).length === 0) {
        throw new AIServiceError(
          'AI response did not contain generated fields. Please try again.',
          {
            statusCode: 502,
            code: 'AI_INVALID_RESPONSE',
          }
        );
      }

      return result;
    } catch (error) {
      if (error?.isAIServiceError) {
        throw error;
      }

      logger.error('Failed to parse AI response:', error);
      logger.error('Raw response:', responseText);
      throw new AIServiceError('AI response was not valid JSON. Please try again.', {
        statusCode: 502,
        code: 'AI_INVALID_RESPONSE',
        cause: error,
      });
    }
  }
}

module.exports = new AIService();
