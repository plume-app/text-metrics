# frozen_string_literal: true

require "text/hyphen"

module TextMetrics
  module Processors
    class Base
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
      def to_h
        METRICS.to_h { |metric| [metric, public_send(metric)] }
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

      # averages
      def syllables_per_word_average
        return 0.0 if words_count.zero? || syllables_count.zero?

        (syllables_count.to_f / words_count).round(1)
      end

      def letters_per_word_average
        return 0.0 if words_count.zero? || characters_count.zero?

        (characters_count.to_f / words_count).round(2)
      end

      def words_per_sentence_average
        return 0.0 if words_count.zero? || sentences_count.zero?

        (words_count.to_f / sentences_count).round(2)
      end

      def characters_per_sentence_average
        return 0.0 if characters_count.zero? || sentences_count.zero?

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

      # readability scores
      def flesch_reading_ease
        raise NotImplementedError
      end

      def flesch_kincaid_grade
        raise NotImplementedError
      end

      def smog_index
        return 0.0 if sentences_count < 3

        smog = 1.043 * Math.sqrt(30.0 * count_polysyllabic_words / sentences_count) + 3.1291
        smog.round(1)
      rescue ZeroDivisionError
        0.0
      end

      def coleman_liau_index
        return 0.0 if words_per_sentence_average.zero? || letters_per_word_average.zero?

        letters = (letters_per_word_average * 100).round(2)
        sentences = (1.to_f / words_per_sentence_average * 100).round(2)
        coleman = 0.0588 * letters - 0.296 * sentences - 15.8
        coleman.round(2).clamp(0.0, 20.0)
      end

      def lix
        return 0.0 if words_count.zero?

        long_words = words.count { |word| word.length > 6 }
        per_long_words = 100.0 * long_words / words_count

        (words_per_sentence_average + per_long_words).round(2).clamp(0.0, 100.0)
      end

      private

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
