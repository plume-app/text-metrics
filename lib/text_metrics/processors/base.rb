# frozen_string_literal: true

require "text/hyphen"

module TextMetrics
  module Processors
    class Base
      GEM_PATH = File.dirname(__FILE__, 2).freeze

      # Single source of truth: #to_h and reader methods are both derived from this list.
      METRICS = %i[
        words_count
        characters_count
        sentences_count
        syllables_count
        punctuation_count
        polysyllabic_words_count
        long_words_count
        syllables_per_word_average
        letters_per_word_average
        words_per_sentence_average
        characters_per_sentence_average
        words_per_punctuation_average
        punctuation_per_sentence_average
        type_token_ratio
        flesch_reading_ease
        flesch_kincaid_grade
        lix
        smog_index
        gunning_fog_index
        coleman_liau_index
        automated_readability_index
        reading_time
      ].freeze

      attr_reader :text, :language

      def initialize(text, language: nil)
        @text = (text || "").squeeze(" ")
        @language = language
      end

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

      def polysyllabic_words_count
        words.count { |word| count_syllables_in_word(word) >= 3 }
      end

      def long_words_count
        words.count { |word| word.length > 6 }
      end

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

      def type_token_ratio
        return 0.0 if words_count.zero?

        (words.uniq.size.to_f / words_count).round(2)
      end

      def flesch_reading_ease
        raise NotImplementedError
      end

      def flesch_kincaid_grade
        return 0.0 if words_count.zero?

        (0.39 * average_words_per_sentence + 11.8 * average_syllables_per_word - 15.59).round(1)
      end

      def smog_index
        return 0.0 if sentences_count < 3

        (1.043 * Math.sqrt(30.0 * polysyllabic_words_count / sentences_count) + 3.1291).round(1)
      rescue ZeroDivisionError
        0.0
      end

      def gunning_fog_index
        return 0.0 if words_count.zero?

        (0.4 * (average_words_per_sentence + 100.0 * polysyllabic_words_count / words_count)).round(1)
      end

      def coleman_liau_index
        return 0.0 if words_count.zero?

        letters_per_100_words = average_letters_per_word * 100
        sentences_per_100_words = sentences_count.to_f / words_count * 100

        (0.0588 * letters_per_100_words - 0.296 * sentences_per_100_words - 15.8).round(2)
      end

      def lix
        return 0.0 if words_count.zero?

        (average_words_per_sentence + 100.0 * long_words_count / words_count).round(2)
      end

      def automated_readability_index
        return 0.0 if words_count.zero?

        (4.71 * characters_count / words_count.to_f + 0.5 * average_words_per_sentence - 21.43).round(1)
      end

      def reading_time(wpm: nil)
        wpm ||= TextMetrics.configuration.wpm
        return 0.0 if words_count.zero? || wpm.zero?

        (words_count / wpm.to_f).round(2)
      end

      private

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

      def letters_count
        @letters_count ||= text.scan(/[[:alpha:]]/).size
      end

      def count_syllables_in_word(word)
        raise NotImplementedError
      end

      def punctuation_marks
        @punctuation_marks ||= text.scan(/[.,!?;:]/)
      end

      def words
        @words ||= text.downcase.strip.scan(/\b[A-Za-zÀ-ÖØ-öø-ÿ'-]+\b/)
      end

      def sentences
        @sentences ||= text.scan(/(?<!\w\.\w.)(?<![A-Z][a-z]\.)(?<=\.|\?|!)(?=\s|$)/)
      end
    end
  end
end
