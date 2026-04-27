const vocabularyModel = require('../models/vocabulary.model');
const reviewModel = require('../models/review.model');
const logger = require('../utils/logger');
const aiService = require('./ai.service');
const { PaginationUtil } = require('../utils');
class ForbiddenError extends Error {
  constructor(message = 'User does not have permission for this action.') {
    super(message);
    this.name = 'ForbiddenError';
    this.isForbidden = true;
  }
}
class ValidationError extends Error {
  constructor(errors) {
    super('Validation failed.');
    this.name = 'ValidationError';
    this.isValidationError = true;
    this.errors = errors;
  }
}

class VocabularyService {
  // =================================================================
  //  VOCABULARY LISTS
  // =================================================================

  async createList(listData, creatorId) {
    const { data, error } = await vocabularyModel.createListWithTags({
      ...listData,
      creatorId,
    });

    if (error) {
      if (error.message.includes('does not exist')) {
        throw new ValidationError([{ field: 'tags', message: error.message }]);
      }
      throw error;
    }

    data.tags = data.tags.map((t) => t.name);
    return data;
  }

  async findUserLists(userId, options) {
    const { page = null, limit = null } = options;
    let from = null,
      to = null,
      pagination = null;

    if (page !== null && limit !== null) {
      pagination = PaginationUtil.validate(page, limit);
      from = pagination.offset;
      to = pagination.offset + pagination.limit - 1;
    }

    const { data, error, count } = await vocabularyModel.findUserLists(userId, {
      ...options,
      from,
      to,
    });

    if (error) throw error;

    const lists = data.map((list) => ({
      ...list,
      tags: list.tags.map((t) => t.name),
    }));

    const paginationResult = pagination
      ? PaginationUtil.getMetadata(pagination.page, pagination.limit, count)
      : { totalItems: count || 0 };

    return { lists, pagination: paginationResult };
  }

  async searchPublicLists(options) {
    const { page = null, limit = null } = options;
    let from = null,
      to = null,
      pagination = null;

    if (page !== null && limit !== null) {
      pagination = PaginationUtil.validate(page, limit);
      from = pagination.offset;
      to = pagination.offset + pagination.limit - 1;
    }

    const { data, error, count } = await vocabularyModel.searchPublicLists({
      ...options,
      from,
      to,
    });

    if (error) throw error;

    const lists = data.map((list) => ({
      ...list,
      tags: list.tags.map((t) => t.name),
    }));

    const paginationResult = pagination
      ? PaginationUtil.getMetadata(pagination.page, pagination.limit, count)
      : { totalItems: count || 0 };

    return { lists, pagination: paginationResult };
  }

  async findListById(listId, userId, skipPermissionCheck = false) {
    const { data: list, error } = await vocabularyModel.findListById(listId);
    if (error || !list) return null;

    if (
      !skipPermissionCheck &&
      list.privacy_setting === 'private' &&
      list.creator_id !== userId
    ) {
      throw new ForbiddenError(
        'You do not have permission to view this private list.'
      );
    }

    if (!skipPermissionCheck) {
      await vocabularyModel.upsertListHistory(userId, listId).catch((err) => {
        logger.error(
          `Failed to update history for user ${userId} and list ${listId}:`,
          err
        );
      });
    }

    list.tags = list.tags.map((t) => t.name);
    return list;
  }

  async findHistoryLists(userId, { page = null, limit = null }) {
    let from = null,
      to = null,
      pagination = null;

    if (page !== null && limit !== null) {
      pagination = PaginationUtil.validate(page, limit);
      from = pagination.offset;
      to = pagination.offset + pagination.limit - 1;
    }

    const { data, error, count } = await vocabularyModel.findHistoryLists(
      userId,
      from,
      to
    );
    if (error) throw error;

    const paginationResult = pagination
      ? PaginationUtil.getMetadata(pagination.page, pagination.limit, count)
      : { totalItems: count || 0 };

    return {
      lists: data || [],
      pagination: paginationResult,
    };
  }

  async findPopularLists({ page = null, limit = null }) {
    let from = null,
      to = null,
      pagination = null;

    if (page !== null && limit !== null) {
      pagination = PaginationUtil.validate(page, limit);
      from = pagination.offset;
      to = pagination.offset + pagination.limit - 1;
    }

    const { data, error, count } = await vocabularyModel.findPopularLists(from, to);
    if (error) throw error;

    const paginationResult = pagination
      ? PaginationUtil.getMetadata(pagination.page, pagination.limit, count)
      : { totalItems: count || 0 };

    return {
      lists: data || [],
      pagination: paginationResult,
    };
  }

  async updateList(listId, userId, updateData) {
    await this._verifyListOwnership(listId, userId);

    const { title, description, privacy_setting, tags } = updateData;
    const allowedUpdates = { title, description, privacy_setting };

    if (tags) {
      const tagIds = await this._validateAndGetTagIds(tags);
      await vocabularyModel.disassociateAllTagsFromList(listId);
      if (tagIds.length > 0) {
        const listTagRelations = tagIds.map((tagId) => ({
          list_id: listId,
          tag_id: tagId,
        }));
        const { error: tagsError } =
          await vocabularyModel.associateTagsToList(listTagRelations);
        if (tagsError) throw tagsError;
      }
    }

    const { data: updatedList, error } = await vocabularyModel.updateList(
      listId,
      allowedUpdates
    );
    if (error) throw error;

    updatedList.tags = updatedList.tags.map((t) => t.name);
    return updatedList;
  }

  async deleteList(listId, userId) {
    await this._verifyListOwnership(listId, userId);
    const { error } = await vocabularyModel.deleteList(listId);
    if (error) throw error;
  }

  // =================================================================
  //  WORDS
  // =================================================================

  async createWord(listId, wordData, userId) {
    await this._verifyListOwnership(listId, userId);

    const {
      term,
      definition,
      translation,
      phonetics,
      image_url,
      exampleSentence,
      synonyms,
      aiGenerated,
      generationPrompt,
    } = wordData;

    // 1. Create the core word
    const { data: newWord, error } = await vocabularyModel.createWord({
      list_id: listId,
      term,
      definition,
      translation,
      phonetics,
      image_url,
      created_by: userId,
    });
    if (error) throw error;

    // 2. Add the optional example
    if (exampleSentence) {
      await vocabularyModel.upsertExample(newWord.id, {
        exampleSentence,
        aiGenerated: aiGenerated || false,
        generationPrompt: generationPrompt || null,
      });
    }

    // 3. Add the optional synonyms
    if (synonyms && Array.isArray(synonyms) && synonyms.length > 0) {
      const synonymsToInsert = synonyms.map((s) => ({
        word_id: newWord.id,
        synonym: s.trim(),
      }));
      await vocabularyModel.createSynonyms(synonymsToInsert).catch((err) => {
        logger.error(`Failed to add synonyms for new word ${newWord.id}:`, err);
      });
    }

    // 4. create default user word progress
    await reviewModel.createDefaultWordProgress(userId, newWord.id);

    await vocabularyModel.updateWordCount(listId);

    // Return the full, newly created word object
    const { data: finalWord, error: fetchError } = await vocabularyModel.findById(
      newWord.id
    );
    if (fetchError) throw fetchError;
    return finalWord;
  }

  async createWordsBulk(listId, words, userId) {
    await this._verifyListOwnership(listId, userId);

    const { wordsToInsert, errors } = this._prepareBulkWords(listId, words, userId);

    if (wordsToInsert.length === 0) {
      return { createdCount: 0, failedCount: errors.length, errors };
    }

    const { data: newWords, error: insertError } =
      await vocabularyModel.createWordsBulkAndReturn(wordsToInsert);
    if (insertError) throw insertError;

    const finalExamples = this._mapSubItemsToNewWords(words, newWords, 'example');
    const finalSynonyms = this._mapSubItemsToNewWords(words, newWords, 'synonym');

    if (finalExamples.length > 0) {
      try {
        const result = await vocabularyModel.createExamplesBulk(finalExamples);
        if (result.error) {
          logger.error('Bulk example creation failed:', result.error);
        }
      } catch (err) {
        logger.error('Bulk example creation failed with exception:', err);
      }
    }
    if (finalSynonyms.length > 0) {
      await vocabularyModel
        .createSynonyms(finalSynonyms)
        .catch((err) => logger.error('Bulk synonym creation failed:', err));
    }

    if (newWords && newWords.length > 0) {
      const progressRecords = newWords.map((word) => ({
        user_id: userId,
        word_id: word.id,
        next_review_date: new Date().toISOString(),
        interval_days: 0,
        ease_factor: 2.5,
        repetitions: 0,
      }));
      await reviewModel.createDefaultWordProgressBulk(progressRecords);
    }

    await vocabularyModel.updateWordCount(listId);
    return { createdCount: newWords.length, failedCount: errors.length, errors };
  }

  async updateWord(wordId, userId, updateData) {
    await this._verifyWordPermission(wordId, userId);

    const {
      term,
      definition,
      translation,
      phonetics,
      image_url,
      exampleSentence,
      synonyms,
      aiGenerated,
      generationPrompt,
    } = updateData;

    // 1. Update core word fields
    const wordFieldsToUpdate = {
      term,
      definition,
      translation,
      phonetics,
      image_url,
    };
    const cleanedWordUpdates = Object.fromEntries(
      Object.entries(wordFieldsToUpdate).filter(([_, v]) => v !== undefined)
    );
    if (Object.keys(cleanedWordUpdates).length > 0) {
      await vocabularyModel.updateWord(wordId, cleanedWordUpdates);
    }

    // 2. Update the example (if provided)
    if (exampleSentence !== undefined) {
      if (exampleSentence) {
        await vocabularyModel.upsertExample(wordId, {
          exampleSentence,
          aiGenerated: aiGenerated || false,
          generationPrompt: generationPrompt || null,
        });
      } else {
        await vocabularyModel.deleteExample(wordId);
      }
    }

    // 3. Overwrite synonyms (if provided)
    if (synonyms !== undefined) {
      await vocabularyModel.deleteSynonymsByWordId(wordId); // Clear existing
      if (synonyms.length > 0) {
        const synonymsToInsert = synonyms.map((s) => ({
          word_id: wordId,
          synonym: s.trim(),
        }));
        await vocabularyModel.createSynonyms(synonymsToInsert);
      }
    }

    const { data: finalWord, error: fetchError } =
      await vocabularyModel.findById(wordId);
    if (fetchError) throw fetchError;
    return finalWord;
  }

  async deleteWord(wordId, userId) {
    const listId = await this._verifyWordPermission(wordId, userId);
    const { error } = await vocabularyModel.deleteWord(wordId);
    if (error) throw error;

    await vocabularyModel.updateWordCount(listId);
  }

  async findWordsByListId(listId, userId, { page = null, limit = null }) {
    await this.findListById(listId, userId);
    let from = null,
      to = null,
      pagination = null;

    if (page !== null && limit !== null) {
      pagination = PaginationUtil.validate(page, limit);
      from = pagination.offset;
      to = pagination.offset + pagination.limit - 1;
    }

    const {
      data: words,
      error,
      count,
    } = await vocabularyModel.findWordsByListId(listId, from, to);
    if (error) throw error;

    const paginationResult = pagination
      ? PaginationUtil.getMetadata(pagination.page, pagination.limit, count)
      : { totalItems: count || 0 };

    return { words, pagination: paginationResult };
  }

  async findWordById(wordId, userId) {
    await this._verifyWordPermission(wordId, userId, 'read');

    const { data: word, error } = await vocabularyModel.findById(wordId);
    if (error) throw error;

    const userProgress = await reviewModel.findProgressByWordId(userId, wordId);

    return {
      ...word,
      userProgress: userProgress,
    };
  }

  async searchWordsInList(listId, userId, options) {
    const { page = null, limit = null, sortBy, q } = options;
    await this.findListById(listId, userId);
    if (sortBy && sortBy.split(':').length !== 2) {
      throw new ValidationError([
        { field: 'sortBy', message: 'Invalid sort format.' },
      ]);
    }
    let from = null,
      to = null,
      pagination = null;

    if (page !== null && limit !== null) {
      pagination = PaginationUtil.validate(page, limit);
      from = pagination.offset;
      to = pagination.offset + pagination.limit - 1;
    }

    const {
      data: words,
      error,
      count,
    } = await vocabularyModel.searchInList(listId, { q, sortBy, from, to });
    if (error) throw error;

    const paginationResult = pagination
      ? PaginationUtil.getMetadata(pagination.page, pagination.limit, count)
      : { totalItems: count || 0 };

    return { words, pagination: paginationResult };
  }

  async generateExample(wordId, userId, context = null) {
    await this._verifyWordPermission(wordId, userId, 'write');

    const { data: word, error } = await vocabularyModel.findById(wordId);
    if (error || !word) throw new Error('Word not found');

    if (!aiService.isAvailable()) {
      throw this._createAIUnavailableError();
    }

    try {
      const example = await aiService.generateExample(
        word.term,
        word.definition,
        context
      );

      const generationPrompt = `Generate example for "${word.term}" (${word.definition})${context ? ` in context: ${context}` : ''}`;

      await vocabularyModel.upsertExample(wordId, {
        exampleSentence: example,
        aiGenerated: true,
        generationPrompt: generationPrompt,
      });

      return {
        wordId,
        term: word.term,
        example,
        aiGenerated: true,
        generationPrompt: generationPrompt,
      };
    } catch (error) {
      logger.error(`Failed to generate example for word ${wordId}:`, error);
      if (error.isAIServiceError) throw error;
      throw new Error('Failed to generate example sentence. Please try again.');
    }
  }

  async generateExampleForNewWord(term, definition, context = null) {
    if (!aiService.isAvailable()) {
      throw this._createAIUnavailableError();
    }

    try {
      const example = await aiService.generateExample(term, definition, context);
      const generationPrompt = `Generate example for "${term}" (${definition})${context ? ` in context: ${context}` : ''}`;

      return {
        term: term,
        example,
        aiGenerated: true,
        generationPrompt: generationPrompt,
      };
    } catch (error) {
      logger.error(`Failed to generate example for new word ${term}:`, error);
      if (error.isAIServiceError) throw error;
      throw new Error('Failed to generate example sentence. Please try again.');
    }
  }

  async generateMissingFields(wordId, userId, currentData = {}, context = null) {
    await this._verifyWordPermission(wordId, userId, 'write');

    const { data: word, error } = await vocabularyModel.findById(wordId);
    if (error || !word) throw new Error('Word not found');

    if (!aiService.isAvailable()) {
      throw this._createAIUnavailableError();
    }

    try {
      const normalizedCurrentData = this._normalizeAICurrentData(currentData);
      const hasCurrentData = (field) =>
        Object.prototype.hasOwnProperty.call(normalizedCurrentData, field);

      // Merge word data with current data - prioritize currentData even if empty
      const mergedData = {
        phonetics: hasCurrentData('phonetics')
          ? normalizedCurrentData.phonetics
          : word.phonetics || '',
        synonyms: hasCurrentData('synonyms')
          ? normalizedCurrentData.synonyms
          : word.synonyms || [],
        translation: hasCurrentData('translation')
          ? normalizedCurrentData.translation
          : word.translation || '',
        exampleSentence: hasCurrentData('exampleSentence')
          ? normalizedCurrentData.exampleSentence
          : word.exampleSentence || '',
      };

      console.log('🔄 Current data from frontend:', normalizedCurrentData);
      console.log('🔄 Word data from database:', {
        phonetics: word.phonetics,
        synonyms: word.synonyms,
        translation: word.translation,
        exampleSentence: word.exampleSentence,
      });
      console.log('🔄 Merged data being checked for missing fields:', mergedData);

      const generatedFields = await aiService.generateMissingFields(
        word.term,
        word.definition,
        mergedData,
        context
      );

      console.log('🤖 AI generated fields:', generatedFields);

      const generationPrompt = `Generate missing fields for "${word.term}" (${word.definition})${context ? ` in context: ${context}` : ''}`;

      // Separate update data for different tables
      const vocabularyUpdateData = {
        aiGenerated: true,
        generationPrompt: generationPrompt,
      };

      // Add phonetics and translation to vocabulary table
      if (generatedFields.phonetics) {
        vocabularyUpdateData.phonetics = generatedFields.phonetics;
      }
      if (generatedFields.translation) {
        vocabularyUpdateData.translation = generatedFields.translation;
      }

      console.log(
        '📝 Data being sent to vocabulary table update:',
        vocabularyUpdateData
      );

      // Update vocabulary table
      try {
        await vocabularyModel.updateWord(wordId, vocabularyUpdateData);
        console.log('✅ Vocabulary table updated successfully');
      } catch (error) {
        console.error('❌ Error updating vocabulary table:', error);
        throw error;
      }

      // Handle synonyms separately
      if (generatedFields.synonyms && generatedFields.synonyms.length > 0) {
        console.log('🔄 Updating synonyms:', generatedFields.synonyms);
        try {
          await vocabularyModel.clearSynonyms(wordId);
          console.log('✅ Cleared existing synonyms');
          for (const synonym of generatedFields.synonyms) {
            await vocabularyModel.addSynonym(wordId, synonym);
          }
          console.log('✅ Added new synonyms successfully');
        } catch (error) {
          console.error('❌ Error updating synonyms:', error);
          throw error;
        }
      }

      // Handle example sentence separately
      if (generatedFields.exampleSentence) {
        console.log(
          '🔄 Updating example sentence:',
          generatedFields.exampleSentence
        );
        try {
          await vocabularyModel.upsertExample(wordId, {
            exampleSentence: generatedFields.exampleSentence,
            aiGenerated: true,
          });
          console.log('✅ Example sentence updated successfully');
        } catch (error) {
          console.error('❌ Error updating example sentence:', error);
          throw error;
        }
      }

      const result = {
        wordId,
        term: word.term,
        generatedFields,
        aiGenerated: true,
        generationPrompt: generationPrompt,
      };

      console.log('✅ Successfully completed field generation. Returning:', result);
      return result;
    } catch (error) {
      logger.error(`Failed to generate missing fields for word ${wordId}:`, error);
      if (error.isAIServiceError) throw error;
      throw new Error('Failed to generate missing fields. Please try again.');
    }
  }

  async generateMissingFieldsForNewWord(
    term,
    definition,
    currentData = {},
    context = null
  ) {
    if (!aiService.isAvailable()) {
      throw this._createAIUnavailableError();
    }

    try {
      const normalizedCurrentData = this._normalizeAICurrentData(currentData);

      const generatedFields = await aiService.generateMissingFields(
        term,
        definition,
        normalizedCurrentData,
        context
      );

      const generationPrompt = `Generate missing fields for "${term}" (${definition})${context ? ` in context: ${context}` : ''}`;

      return {
        term: term,
        generatedFields,
        aiGenerated: true,
        generationPrompt: generationPrompt,
      };
    } catch (error) {
      logger.error(`Failed to generate missing fields for new word ${term}:`, error);
      if (error.isAIServiceError) throw error;
      throw new Error('Failed to generate missing fields. Please try again.');
    }
  }

  // =================================================================
  //  SYNONYMS
  // =================================================================

  async addSynonyms(wordId, synonyms, userId) {
    await this._verifyWordPermission(wordId, userId);
    if (!synonyms || !Array.isArray(synonyms) || synonyms.length === 0) {
      throw new ValidationError([
        {
          field: 'synonyms',
          message: 'Synonyms must be a non-empty array of strings.',
        },
      ]);
    }
    const synonymsToInsert = synonyms.map((s) => ({
      word_id: wordId,
      synonym: s.trim(),
    }));
    const { error } = await vocabularyModel.createSynonyms(synonymsToInsert);
    if (error) throw error;
    return { wordId, addedCount: synonyms.length, synonymsAdded: synonyms };
  }

  async deleteSynonym(wordId, synonym, userId) {
    await this._verifyWordPermission(wordId, userId);
    const { error } = await vocabularyModel.deleteSynonym(wordId, synonym);
    if (error) throw error;
  }

  // =================================================================
  //  TAGS
  // =================================================================

  async findAllTags() {
    const { data, error } = await vocabularyModel.findAllTags();
    if (error) throw error;
    return data.map((tag) => tag.name);
  }

  // =================================================================
  //  PRIVATE HELPER METHODS
  // =================================================================

  async _verifyListOwnership(listId, userId) {
    const { data: list, error } = await vocabularyModel.findListOwner(listId);
    if (error || !list) throw new Error('List not found.');
    if (list.creator_id !== userId) throw new ForbiddenError();
  }

  async _verifyWordPermission(wordId, userId, accessType = 'write') {
    const { data: word, error } = await vocabularyModel.findWordWithListInfo(wordId);
    if (error || !word) throw new Error('Word not found.');
    if (accessType === 'read' && word.vocab_lists.privacy_setting === 'public') {
      return word.list_id;
    }
    if (word.vocab_lists.creator_id !== userId) throw new ForbiddenError();
    return word.list_id;
  }

  async _verifyExamplePermission(exampleId, userId) {
    const { data: example, error } =
      await vocabularyModel.findExampleWithListInfo(exampleId);
    if (error || !example) throw new Error('Example not found.');
    if (example.vocabulary.vocab_lists.creator_id !== userId)
      throw new ForbiddenError();
  }

  async _validateAndGetTagIds(tagNames) {
    if (!tagNames || tagNames.length === 0) return [];
    const { data: existingTags, error } =
      await vocabularyModel.findTagsByName(tagNames);
    if (error) throw error;
    if (existingTags.length !== tagNames.length) {
      const found = existingTags.map((t) => t.name);
      const invalid = tagNames.filter((name) => !found.includes(name));
      throw new ValidationError([
        { field: 'tags', message: `Invalid tags: ${invalid.join(', ')}` },
      ]);
    }
    return existingTags.map((t) => t.id);
  }

  _prepareBulkWords(listId, words, userId) {
    const wordsToInsert = [];
    const errors = [];
    words.forEach((word, index) => {
      if (word.term && word.definition) {
        wordsToInsert.push({
          list_id: listId,
          term: word.term,
          definition: word.definition,
          translation: word.translation,
          phonetics: word.phonetics,
          image_url: word.image_url,
          created_by: userId,
        });
      } else {
        errors.push({
          itemIndex: index,
          term: word.term || 'N/A',
          reason: 'Term and definition are required fields.',
        });
      }
    });
    return { wordsToInsert, errors };
  }

  _mapSubItemsToNewWords(originalWords, newWords, itemType) {
    const itemsToInsert = [];
    originalWords.forEach((originalWord) => {
      const newWord = newWords.find((nw) => nw.term === originalWord.term);
      if (!newWord) return;

      if (itemType === 'example' && originalWord.exampleSentence) {
        const exampleData = {
          vocabulary_id: newWord.id,
          example_sentence: originalWord.exampleSentence,
          ai_generated: originalWord.aiGenerated || false,
          generation_prompt: originalWord.generationPrompt || null,
        };
        itemsToInsert.push(exampleData);
      }
      if (itemType === 'synonym' && originalWord.synonyms) {
        originalWord.synonyms.forEach((synonym) => {
          itemsToInsert.push({ word_id: newWord.id, synonym: synonym.trim() });
        });
      }
    });
    return itemsToInsert;
  }

  _createAIUnavailableError() {
    const error = new Error(
      'AI service is temporarily unavailable. Please check Gemini configuration.'
    );
    error.name = 'AIServiceError';
    error.isAIServiceError = true;
    error.statusCode = 503;
    error.code = 'AI_UNAVAILABLE';
    error.userMessage = error.message;
    error.publicDetails = { code: error.code };
    return error;
  }

  _normalizeAICurrentData(currentData = {}) {
    const source = currentData || {};
    const has = (field) => Object.prototype.hasOwnProperty.call(source, field);
    const normalizeString = (value) => {
      if (typeof value === 'string') return value;
      if (value === null || value === undefined) return '';
      return String(value);
    };
    const normalizeSynonyms = (synonyms) => {
      if (Array.isArray(synonyms)) {
        return synonyms
          .filter((synonym) => typeof synonym === 'string')
          .map((synonym) => synonym.trim())
          .filter(Boolean);
      }

      if (typeof synonyms === 'string') {
        return synonyms
          .split(',')
          .map((synonym) => synonym.trim())
          .filter(Boolean);
      }

      return [];
    };

    const normalized = {};

    if (has('phonetics') || has('pronunciation')) {
      normalized.phonetics = normalizeString(
        source.phonetics ?? source.pronunciation
      );
    }

    if (has('synonyms')) {
      normalized.synonyms = normalizeSynonyms(source.synonyms);
    }

    if (has('translation')) {
      normalized.translation = normalizeString(source.translation);
    }

    if (has('exampleSentence') || has('example')) {
      normalized.exampleSentence = normalizeString(
        source.exampleSentence ?? source.example
      );
    }

    return normalized;
  }
}

module.exports = new VocabularyService();
