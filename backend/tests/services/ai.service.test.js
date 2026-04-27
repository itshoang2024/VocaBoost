let mockGenerateContent;

jest.mock('@google/genai', () => ({
  GoogleGenAI: jest.fn().mockImplementation(() => ({
    models: {
      generateContent: mockGenerateContent,
    },
  })),
}));

describe('AIService', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    jest.resetModules();
    mockGenerateContent = jest.fn();
    process.env = {
      ...originalEnv,
      GEMINI_API_KEY: 'test-key',
      NODE_ENV: 'test',
    };
    delete process.env.GEMINI_MODEL;
    delete process.env.MODEL_ID;
  });

  afterEach(() => {
    process.env = originalEnv;
  });

  it('uses MODEL_ID as a legacy fallback for the configured Gemini model', () => {
    process.env.MODEL_ID = 'legacy-test-model';

    const aiService = require('../../src/services/ai.service');

    expect(aiService.model).toBe('legacy-test-model');
  });

  it('maps Gemini quota exhaustion to a public 429 error', async () => {
    mockGenerateContent.mockRejectedValue(
      new Error(
        JSON.stringify({
          error: {
            code: 429,
            message: 'Quota exceeded. Please retry in 14.877455253s.',
            status: 'RESOURCE_EXHAUSTED',
            details: [{ retryDelay: '14s' }],
          },
        })
      )
    );

    const aiService = require('../../src/services/ai.service');

    await expect(
      aiService.generateMissingFields('chicken', 'a domestic bird', {
        phonetics: '',
        synonyms: [],
        translation: '',
        exampleSentence: '',
      })
    ).rejects.toMatchObject({
      isAIServiceError: true,
      statusCode: 429,
      code: 'AI_QUOTA_EXHAUSTED',
      retryAfterSeconds: 14,
      publicDetails: {
        code: 'AI_QUOTA_EXHAUSTED',
        retryAfterSeconds: 14,
      },
    });

    expect(mockGenerateContent).toHaveBeenCalledTimes(1);
  });

  it('accepts common alternate field names from Gemini JSON responses', async () => {
    mockGenerateContent.mockResolvedValue({
      text: JSON.stringify({
        pronunciation: '/ˈtʃɪkɪn/',
        synonyms: 'fowl, poultry',
        translation: 'con gà',
        example: 'The chicken walked across the yard.',
      }),
    });

    const aiService = require('../../src/services/ai.service');

    await expect(
      aiService.generateMissingFields('chicken', 'a domestic bird', {
        phonetics: '',
        synonyms: [],
        translation: '',
        exampleSentence: '',
      })
    ).resolves.toEqual({
      phonetics: '/ˈtʃɪkɪn/',
      synonyms: ['fowl', 'poultry'],
      translation: 'con gà',
      exampleSentence: 'The chicken walked across the yard.',
    });
  });

  it('rejects empty structured responses instead of treating them as success', async () => {
    mockGenerateContent.mockResolvedValue({
      text: JSON.stringify({ note: 'No generated fields here.' }),
    });

    const aiService = require('../../src/services/ai.service');

    await expect(
      aiService.generateMissingFields('chicken', 'a domestic bird', {
        phonetics: '',
        synonyms: [],
        translation: '',
        exampleSentence: '',
      })
    ).rejects.toMatchObject({
      isAIServiceError: true,
      statusCode: 502,
      code: 'AI_INVALID_RESPONSE',
      publicDetails: {
        code: 'AI_INVALID_RESPONSE',
      },
    });
  });
});
