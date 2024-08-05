# frozen_string_literal: true

require "text/hyphen"

module TextMetrics
  module Processors
    class Base
      attr_reader :text, :with_syllable_exceptions

      def initialize(text:, with_syllable_exceptions: true)
        @text = text&.downcase&.squeeze(" ") || ""
        @with_syllable_exceptions = with_syllable_exceptions
      end

      def all
        @all ||= {
          words_count: words_count,
          characters_count: characters_count,
          sentences_count: sentences_count,
          syllables_count: syllables_count,
          syllables_per_word_average: syllables_per_word_average,
          letters_per_word_average: letters_per_word_average,
          words_per_sentence_average: words_per_sentence_average,
          characters_per_sentence_average: characters_per_sentence_average,
          flesch_reading_ease: flesch_reading_ease,
          flesch_kincaid_grade: flesch_kincaid_grade
        }
      end

      # _count methods
      def characters_count(ignore_spaces: true)
        ignore_spaces ? text.delete(" ").length : text.length
      end

      def words_count
        words.size
      end

      def sentences_count
        sentences.size
      end

      def syllables_count
        raise NotImplementedError
      end

      # _average methods

      def syllables_per_word_average
        (syllables_count.to_f / words_count).round(1)
      rescue ZeroDivisionError
        0.0
      end

      def letters_per_word_average
        (characters_count.to_f / words_count).round(2)
      rescue ZeroDivisionError
        0.0
      end

      def words_per_sentence_average
        (words_count.to_f / sentences_count).round(2)
      rescue ZeroDivisionError
        0.0
      end

      def characters_per_sentence_average
        (characters_count.to_f / sentences_count).round(2)
      rescue ZeroDivisionError
        0.0
      end

      # readability scores
      def flesch_reading_ease
        raise NotImplementedError
      end

      def flesch_kincaid_grade
        raise NotImplementedError
      end

      # tokenizers

      def words
        @words ||= begin
          normalized_text = text.downcase.strip

          # Split the sentence into words, including hyphenated words, and excluding numbers
          normalized_text.scan(/\b[A-Za-zÀ-ÖØ-öø-ÿ'-]+\b/)
        end
      end

      def sentences
        @sentences ||= text.scan(/(?<!\w\.\w.)(?<![A-Z][a-z]\.)(?<=\.|\?|!)(?=\s|$)/)
      end

      private

      def hyphen_dictionary
        raise NotImplementedError
      end
    end
  end
end
