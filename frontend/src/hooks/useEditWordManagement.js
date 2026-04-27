import { useCallback, useState } from "react";
import { useConfirm } from "../components/Providers/ConfirmProvider.jsx";
import { useToast } from "../components/Providers/ToastProvider.jsx";
import vocabularyService from "../services/Vocabulary/vocabularyService";
import { EMPTY_WORD } from "../constants/vocabulary.js";

export const useEditWordManagement = () => {
  const [words, setWords] = useState([]);
  const [originalWords, setOriginalWords] = useState([]);
  const [selectedWordIds, setSelectedWordIds] = useState(new Set());
  const [loadingAI, setLoadingAI] = useState(new Set());

  const confirm = useConfirm();
  const toast = useToast();

  const normalizeSynonyms = useCallback((input) => {
    if (!input) return [];
    if (Array.isArray(input)) {
      return input
        .map((s) => (typeof s === "string" ? s.trim() : ""))
        .filter((s) => s !== "");
    }
    if (typeof input === "string") {
      return input
        .split(",")
        .map((s) => s.trim())
        .filter((s) => s !== "");
    }
    return [];
  }, []);

  const addWord = useCallback(() => {
    setWords((prev) => [...prev, { ...EMPTY_WORD }]);
  }, []);

  const deleteWord = useCallback(
    async (index) => {
      const confirmed = await confirm(
        "Are you sure you want to delete this word?"
      );
      if (!confirmed) return;

      setWords((prev) => prev.filter((_, i) => i !== index));
      setSelectedWordIds((prev) => {
        const newSelected = new Set(prev);
        newSelected.delete(words[index]?.id);
        return newSelected;
      });
    },
    [confirm, words]
  );

  const deleteSelectedWords = useCallback(async () => {
    const confirmed = await confirm("Delete selected words?");
    if (!confirmed) return;

    setWords((prev) => prev.filter((word) => !selectedWordIds.has(word.id)));
    setSelectedWordIds(new Set());
  }, [confirm, selectedWordIds]);

  const updateWord = useCallback((index, field, value) => {
    setWords((prev) => {
      const updated = [...prev];
      updated[index] = { ...updated[index], [field]: value };
      return updated;
    });
  }, []);

  // Edit-specific: Toggle selection by word ID, not index
  const toggleWordSelection = useCallback(
    (index) => {
      const word = words[index];
      if (!word?.id) return; // Can't select words without IDs

      setSelectedWordIds((prev) => {
        const updated = new Set(prev);
        if (updated.has(word.id)) {
          updated.delete(word.id);
        } else {
          updated.add(word.id);
        }
        return updated;
      });
    },
    [words]
  );

  // Edit-specific: Handle both existing and new words for AI generation
  const generateMissingFields = useCallback(
    async (index) => {
      // Validate inputs first
      if (index < 0 || index >= words.length) {
        console.error("Invalid word index:", index);
        toast("Invalid word selection. Please refresh and try again.", "error");
        return;
      }

      const word = words[index];

      if (!word) {
        console.error("Word not found at index:", index);
        toast("Word not found. Please refresh and try again.", "error");
        return;
      }

      if (!word.term?.trim() || !word.definition?.trim()) {
        toast("Please add term and definition first.", "error");
        return;
      }

      // Prevent double-clicking
      if (loadingAI.has(index)) {
        return;
      }

      setLoadingAI((prev) => new Set(prev).add(index));

      try {
        let response;

        // Helper function to check if field is truly empty (null, undefined, empty string, or only spaces)
        const isFieldEmpty = (value) => {
          if (!value) return true;
          if (typeof value === "string") return value.trim() === "";
          if (Array.isArray(value)) {
            return (
              value.length === 0 ||
              value.every((item) => !item || item.trim() === "")
            );
          }
          return false;
        };

        // Prepare current data for the word - treat empty/space-only fields as truly empty
        const currentData = {
          phonetics: isFieldEmpty(word.phonetics) ? "" : word.phonetics.trim(),
          synonyms: isFieldEmpty(word.synonyms)
            ? []
            : Array.isArray(word.synonyms)
              ? word.synonyms
                  .filter((s) => s && s.trim() !== "")
                  .map((s) => s.trim())
              : typeof word.synonyms === "string" && word.synonyms.trim() !== ""
                ? word.synonyms
                    .split(",")
                    .map((s) => s.trim())
                    .filter((s) => s !== "")
                : [],
          translation: isFieldEmpty(word.translation)
            ? ""
            : word.translation.trim(),
          exampleSentence: isFieldEmpty(word.exampleSentence)
            ? ""
            : word.exampleSentence.trim(),
        };

        console.log("Word data:", word);
        console.log("Current data being sent to AI:", currentData);

        // If word has an ID (existing word), use the word-specific endpoint
        if (word.id) {
          response = await vocabularyService.generateMissingFields(word.id, {
            currentData,
            // Don't send context parameter if not needed (context is optional)
          });
        } else {
          // If word doesn't have ID (new word), use the general endpoint
          response = await vocabularyService.generateMissingFields(null, {
            term: word.term.trim(),
            definition: word.definition.trim(),
            currentData,
          });
        }

        console.log("AI Response:", response); // Debug log

        if (response?.data?.result?.generatedFields) {
          console.log(
            "Generated fields received:",
            response.data.result.generatedFields
          );

          try {
            // Use functional update to ensure we have the latest state
            setWords((currentWords) => {
              if (index >= currentWords.length) {
                console.error("Word index out of bounds during update:", index);
                return currentWords;
              }

              const updated = [...currentWords];
              const generatedFields = response.data.result.generatedFields;

              console.log(
                "Before update - word at index",
                index,
                ":",
                updated[index]
              );
              console.log("Fields to update:", generatedFields);

              // Update only the fields that were generated - match backend field names exactly
              const updatedFields = {};

              if ("phonetics" in generatedFields && generatedFields.phonetics) {
                updatedFields.phonetics = generatedFields.phonetics;
              }

              if ("synonyms" in generatedFields && generatedFields.synonyms) {
                updatedFields.synonyms = Array.isArray(generatedFields.synonyms)
                  ? generatedFields.synonyms.join(", ")
                  : generatedFields.synonyms;
              }

              if (
                "translation" in generatedFields &&
                generatedFields.translation
              ) {
                updatedFields.translation = generatedFields.translation;
              }

              if (
                "exampleSentence" in generatedFields &&
                generatedFields.exampleSentence
              ) {
                updatedFields.exampleSentence = generatedFields.exampleSentence;
              }

              console.log("Fields being applied to state:", updatedFields);

              updated[index] = {
                ...updated[index],
                ...updatedFields,
                // Store AI metadata for ALL words (both new and existing)
                aiGenerated: response.data.result.aiGenerated || true,
                generationPrompt: response.data.result.generationPrompt || null,
              };

              console.log(
                "After update - word at index",
                index,
                ":",
                updated[index]
              );
              return updated;
            });

            toast("Missing fields generated successfully!", "success");
          } catch (stateError) {
            console.error("Error updating word state:", stateError);
            toast("Generated fields but couldn't save them.", "error");
          }
        } else {
          console.error("Unexpected response structure:", response);
          toast(
            "Failed to generate missing fields. Please try again.",
            "error"
          );
        }
      } catch (error) {
        console.error("Error generating missing fields:", error);
        // More detailed error logging
        if (error.response) {
          console.error("Response data:", error.response.data);
          console.error("Response status:", error.response.status);
        }
        const errorMessage =
          error.response?.data?.message ||
          error.response?.data?.error ||
          "Failed to generate missing fields. Please try again.";
        toast(errorMessage, "error");
      } finally {
        setLoadingAI((prev) => {
          const newSet = new Set(prev);
          newSet.delete(index);
          return newSet;
        });
      }
    },
    [words, toast, loadingAI]
  );

  // Keep the old generateExample method for backward compatibility
  const generateExample = useCallback(
    async (index) => {
      // Validate inputs first
      if (index < 0 || index >= words.length) {
        console.error("Invalid word index:", index);
        toast("Invalid word selection. Please refresh and try again.", "error");
        return;
      }

      const word = words[index];

      if (!word) {
        console.error("Word not found at index:", index);
        toast("Word not found. Please refresh and try again.", "error");
        return;
      }

      if (!word.term?.trim() || !word.definition?.trim()) {
        toast("Please add term and definition first.", "error");
        return;
      }

      // Prevent double-clicking
      if (loadingAI.has(index)) {
        return;
      }

      setLoadingAI((prev) => new Set(prev).add(index));

      try {
        let response;

        // If word has an ID (existing word), use the word-specific endpoint
        if (word.id) {
          response = await vocabularyService.generateExample(word.id, {
            // Don't send context parameter if not needed (context is optional)
          });
        } else {
          // If word doesn't have ID (new word), use the general endpoint
          response = await vocabularyService.generateExample(null, {
            term: word.term.trim(),
            definition: word.definition.trim(),
          });
        }

        console.log("AI Response:", response); // Debug log

        if (response?.data?.example) {
          try {
            // Use functional update to ensure we have the latest state
            setWords((currentWords) => {
              if (index >= currentWords.length) {
                console.error("Word index out of bounds during update:", index);
                return currentWords;
              }

              const updated = [...currentWords];
              const exampleText =
                response.data.example.example || response.data.example;

              updated[index] = {
                ...updated[index],
                exampleSentence: exampleText,
                // Store AI metadata for ALL words (both new and existing)
                aiGenerated: response.data.example.aiGenerated || true,
                generationPrompt:
                  response.data.example.generationPrompt || null,
              };

              return updated;
            });

            toast("Example generated successfully!", "success");
          } catch (stateError) {
            console.error("Error updating word state:", stateError);
            toast("Generated example but couldn't save it.", "error");
          }
        } else {
          console.error("Unexpected response structure:", response);
          toast("Failed to generate example. Please try again.", "error");
        }
      } catch (error) {
        console.error("Error generating example:", error);
        // More detailed error logging
        if (error.response) {
          console.error("Response data:", error.response.data);
          console.error("Response status:", error.response.status);
        }
        const errorMessage =
          error.response?.data?.message ||
          error.response?.data?.error ||
          "Failed to generate example. Please try again.";
        toast(errorMessage, "error");
      } finally {
        setLoadingAI((prev) => {
          const newSet = new Set(prev);
          newSet.delete(index);
          return newSet;
        });
      }
    },
    [words, toast, loadingAI]
  );

  // Return ALL words that have any content - both existing and new words must be validated
  const getValidWords = useCallback(() => {
    return words.filter((w) => {
      const hasMainContent =
        (w.term && w.term.trim() !== "") ||
        (w.definition && w.definition.trim() !== "");
      const hasOptionalContent =
        (w.phonetics && w.phonetics.trim() !== "") ||
        (w.exampleSentence && w.exampleSentence.trim() !== "") ||
        (w.synonyms && w.synonyms.toString().trim() !== "") ||
        (w.translation && w.translation.trim() !== "") ||
        (w.image && w.image.trim() !== "");

      // For EDIT: Any word with content (main or optional) should be validated
      // This includes both existing words (with ID) and new words (without ID)
      const hasAnyContent = hasMainContent || hasOptionalContent;

      if (hasAnyContent) {
        console.log(
          `Word "${w.term}" included for validation (${w.id ? "EXISTING" : "NEW"}):`,
          {
            hasMainContent,
            hasOptionalContent,
            isExisting: !!w.id,
            isNew: !w.id,
          }
        );
      }

      return hasAnyContent;
    });
  }, [words]);

  // Edit-specific: Get words for update operation - returns ALL words with content
  const getWordsForUpdate = useCallback(() => {
    const currentValidWords = getValidWords();

    console.log("Words for update operation:", {
      originalCount: originalWords.length,
      currentValidCount: currentValidWords.length,
      existingInCurrent: currentValidWords.filter((w) => w.id).length,
      newInCurrent: currentValidWords.filter((w) => !w.id).length,
    });

    return {
      originalWords,
      currentWords: currentValidWords,
    };
  }, [originalWords, getValidWords]);

  // Synchronized with useListManagement - improved word preparation
  const prepareWordsForSubmission = useCallback(() => {
    const validWords = getValidWords();
    return validWords.map((w) => ({
      term: w.term || "",
      definition: w.definition || "",
      phonetics: w.phonetics || "",
      synonyms: normalizeSynonyms(w.synonyms),
      translation: w.translation || "",
      // Always include exampleSentence to handle both adding and removing examples
      exampleSentence: w.exampleSentence || "",
      // Include AI metadata only when we have an example with content
      ...(w.exampleSentence && w.exampleSentence.trim() && w.aiGenerated
        ? {
            aiGenerated: w.aiGenerated,
            generationPrompt: w.generationPrompt || null,
          }
        : {}),
      // Keep ID for edit operations
      ...(w.id ? { id: w.id } : {}),
    }));
  }, [getValidWords, normalizeSynonyms]);

  return {
    words,
    setWords,
    originalWords,
    setOriginalWords,
    selectedWordIds,
    loadingAI,
    addWord,
    deleteWord,
    deleteSelectedWords,
    updateWord,
    toggleWordSelection,
    generateExample,
    generateMissingFields,
    getValidWords,
    getWordsForUpdate,
    prepareWordsForSubmission,
  };
};
