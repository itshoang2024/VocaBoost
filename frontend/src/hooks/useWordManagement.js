import { useCallback, useState } from "react";
import { useConfirm } from "../components/Providers/ConfirmProvider.jsx";
import { useToast } from "../components/Providers/ToastProvider.jsx";
import vocabularyService from "../services/Vocabulary/vocabularyService";
import { EMPTY_WORD, INITIAL_WORDS_COUNT } from "../constants/vocabulary.js";

export const useWordManagement = () => {
  const [words, setWords] = useState(
    Array(INITIAL_WORDS_COUNT)
      .fill(null)
      .map(() => ({ ...EMPTY_WORD }))
  );
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
        newSelected.delete(words[index].id);
        return newSelected;
      });
    },
    [confirm, words]
  );

  const deleteSelectedWords = useCallback(async () => {
    const confirmed = await confirm("Delete selected words?");
    if (!confirmed) return;

    setWords((prev) => prev.filter((_, i) => !selectedWordIds.has(i)));
    setSelectedWordIds(new Set());
  }, [confirm, selectedWordIds]);

  const updateWord = useCallback((index, field, value) => {
    setWords((prev) => {
      const updated = [...prev];
      updated[index] = { ...updated[index], [field]: value };
      return updated;
    });
  }, []);

  const toggleWordSelection = useCallback((index) => {
    setSelectedWordIds((prev) => {
      const updated = new Set(prev);
      if (updated.has(index)) {
        updated.delete(index);
      } else {
        updated.add(index);
      }
      return updated;
    });
  }, []);

  const generateMissingFields = useCallback(
    async (index) => {
      const word = words[index];

      if (!word.term.trim() || !word.definition.trim()) {
        toast("Please add term and definition first.", "error");
        return;
      }

      setLoadingAI((prev) => new Set(prev).add(index));

      try {
        console.log("=== Frontend generateMissingFields (New Word) ===");
        console.log("Latest word data:", word);

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

        // Prepare current data for the word with proper empty checking - treat empty/space-only as truly empty
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
          exampleSentence: isFieldEmpty(word.exampleSentence)
            ? ""
            : word.exampleSentence.trim(),
          translation: isFieldEmpty(word.translation)
            ? ""
            : word.translation.trim(),
        };

        console.log("Current data being sent:", currentData);

        const response = await vocabularyService.generateMissingFields(null, {
          term: word.term.trim(),
          definition: word.definition.trim(),
          currentData,
        });

        if (response?.data?.result?.generatedFields) {
          console.log(
            "Generated fields received:",
            response.data.result.generatedFields
          );

          const updatedWords = [...words];
          const generatedFields = response.data.result.generatedFields;

          console.log(
            "Before update - word at index",
            index,
            ":",
            updatedWords[index]
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

          if ("translation" in generatedFields && generatedFields.translation) {
            updatedFields.translation = generatedFields.translation;
          }

          if (
            "exampleSentence" in generatedFields &&
            generatedFields.exampleSentence
          ) {
            updatedFields.exampleSentence = generatedFields.exampleSentence;
          }

          console.log("Fields being applied to state:", updatedFields);

          updatedWords[index] = {
            ...updatedWords[index],
            ...updatedFields,
            aiGenerated: response.data.result.aiGenerated,
            generationPrompt: response.data.result.generationPrompt,
          };

          console.log(
            "After update - word at index",
            index,
            ":",
            updatedWords[index]
          );
          setWords(updatedWords);
          toast("Missing fields generated successfully!", "success");
        } else {
          toast(
            "Failed to generate missing fields. Please try again.",
            "error"
          );
        }
      } catch (error) {
        console.error("Error generating missing fields:", error);
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
    [words, toast]
  );

  const generateExample = useCallback(
    async (index) => {
      const word = words[index];

      if (!word.term.trim() || !word.definition.trim()) {
        toast("Please add term and definition first.", "error");
        return;
      }

      setLoadingAI((prev) => new Set(prev).add(index));

      try {
        const response = await vocabularyService.generateExample(null, {
          term: word.term.trim(),
          definition: word.definition.trim(),
        });

        if (response?.data?.example?.example) {
          const updatedWords = [...words];
          updatedWords[index] = {
            ...updatedWords[index],
            exampleSentence: response.data.example.example,
            aiGenerated: response.data.example.aiGenerated,
            generationPrompt: response.data.example.generationPrompt,
          };
          setWords(updatedWords);
          toast("Example generated successfully!", "success");
        } else {
          toast("Failed to generate example. Please try again.", "error");
        }
      } catch (error) {
        console.error("Error generating example:", error);
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
    [words, toast]
  );

  const getValidWords = useCallback(
    () => words.filter((w) => w.term && w.definition),
    [words]
  );

  const prepareWordsForSubmission = useCallback(() => {
    const validWords = getValidWords();
    const preparedWords = validWords.map((w) => ({
      term: w.term,
      definition: w.definition,
      phonetics: w.phonetics || "",
      synonyms: normalizeSynonyms(w.synonyms),
      translation: w.translation || "",
      exampleSentence: w.exampleSentence || "",
      aiGenerated: w.aiGenerated || false,
      generationPrompt: w.generationPrompt || null,
    }));

    return preparedWords;
  }, [getValidWords, normalizeSynonyms]);

  return {
    words,
    setWords,
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
    prepareWordsForSubmission,
  };
};
