# frozen_string_literal: true

require "text/hyphen"

module TextMetrics
  module Processors
    class Base
      GEM_PATH = File.dirname(__FILE__, 2).freeze

      # The public metric surface. #to_h and the individual readers are both derived
      # from this list, so they can never drift apart.
      METRICS = %i[
        words_count
        characters_count
        sentences_count
        syllables_count
        punctuation_count
        syllables_per_word_average
        letters_per_word_average
        words_per_sentence_average
        characters_per_sentence_average
        words_per_punctuation_average
        punctuation_per_sentence_average
        flesch_reading_ease
        flesch_kincaid_grade
        lix
        smog_index
        coleman_liau_index
      ].freeze

      attr_reader :text, :language

      def initialize(text, language: nil)
        @text = (text || "").squeeze(" ")
        @language = language
      end

      # Every metric in one hash. Single source of truth for the public surface.
      # Memoized — the analyzer is immutable once built.
      def to_h
        @to_h ||= METRICS.to_h { |metric| [metric, public_send(metric)] }
      end

      # counts
      def words_count
        words.size
      end

      def characters_count(ignore_spaces: true)
        ignore_spaces ? text.delete(" ").length : text.length
      end

      def sentences_count
        return 0 if words_count.zero?

        [1, sentences.size].max
      end

      def syllables_count
        words.sum { |word| count_syllables_in_word(word) }
      end

      def punctuation_count
        punctuation_marks.size
      end

      # averages — rounded for display only. The readability scores below are computed
      # from the full-precision ratios (#average_*), not from these rounded values.
      def syllables_per_word_average
        average_syllables_per_word.round(1)
      end

      def letters_per_word_average
        average_letters_per_word.round(2)
      end

      def words_per_sentence_average
        average_words_per_sentence.round(2)
      end

      def characters_per_sentence_average
        return 0.0 if sentences_count.zero?

        (characters_count.to_f / sentences_count).round(2)
      end

      def words_per_punctuation_average
        return 0.0 if words_count.zero? || punctuation_count.zero?

        (words_count.to_f / punctuation_count).round(2)
      end

      def punctuation_per_sentence_average
        return 0.0 if punctuation_count.zero? || sentences_count.zero?

        (punctuation_count.to_f / sentences_count).round(2)
      end

      # readability scores — computed from full-precision ratios, rounded only at the end,
      # and returned unclamped (a Flesch score can legitimately exceed 100 or go negative).

      # Language-specific; subclasses supply the constants.
      def flesch_reading_ease
        raise NotImplementedError
      end

      # Flesch-Kincaid Grade Level (US school grade). The same formula is used for every
      # language — there is no validated non-English adaptation.
      def flesch_kincaid_grade
        return 0.0 if words_count.zero?

        (0.39 * average_words_per_sentence + 11.8 * average_syllables_per_word - 15.59).round(1)
      end

      def smog_index
        return 0.0 if sentences_count < 3

        (1.043 * Math.sqrt(30.0 * count_polysyllabic_words / sentences_count) + 3.1291).round(1)
      rescue ZeroDivisionError
        0.0
      end

      def coleman_liau_index
        return 0.0 if words_count.zero?

        letters_per_100_words = average_letters_per_word * 100
        sentences_per_100_words = sentences_count.to_f / words_count * 100

        (0.0588 * letters_per_100_words - 0.296 * sentences_per_100_words - 15.8).round(2)
      end

      def lix
        return 0.0 if words_count.zero?

        long_words = words.count { |word| word.length > 6 }

        (average_words_per_sentence + 100.0 * long_words / words_count).round(2)
      end

      private

      # full-precision ratios feeding the readability formulas
      def average_syllables_per_word
        return 0.0 if words_count.zero?

        syllables_count.to_f / words_count
      end

      def average_letters_per_word
        return 0.0 if words_count.zero?

        letters_count.to_f / words_count
      end

      def average_words_per_sentence
        return 0.0 if sentences_count.zero?

        words_count.to_f / sentences_count
      end

      # Count of alphabetic characters only (letters), as required by Coleman-Liau and the
      # letters-per-word metric — distinct from #characters_count, which includes digits
      # and punctuation.
      def letters_count
        @letters_count ||= text.scan(/[[:alpha:]]/).size
      end

      # Subclasses provide the language-specific syllable counting.
      def count_syllables_in_word(word)
        raise NotImplementedError
      end

      def count_polysyllabic_words
        words.count { |word| count_syllables_in_word(word) >= 3 }
      end

      # tokenizers
      def punctuation_marks
        @punctuation_marks ||= text.scan(/[.,!?;:]/)
      end

      def words
        @words ||= begin
          normalized_text = text.downcase.strip

          # Split into words, including hyphenated words, and excluding numbers
          normalized_text.scan(/\b[A-Za-zÀ-ÖØ-öø-ÿ'-]+\b/)
        end
      end

      def sentences
        @sentences ||= text.scan(/(?<!\w\.\w.)(?<![A-Z][a-z]\.)(?<=\.|\?|!)(?=\s|$)/)
      end
    end
  end
end
