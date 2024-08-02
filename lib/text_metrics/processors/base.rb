# frozen_string_literal: true

require "text/hyphen"

module TextMetrics
  module Processors
    class Base
      attr_reader :text

      def initialize(text:)
        @text = text.downcase.squeeze(" ")
      end

      def all
        @all ||= {
          word_count: word_count,
          char_count: char_count,
          sentence_count: sentence_count,
          syllable_count: syllable_count,
          avg_sentence_length: avg_sentence_length,
          avg_syllables_per_word: avg_syllables_per_word,
          avg_letter_per_word: avg_letter_per_word,
          avg_words_per_sentence: avg_words_per_sentence,
          flesch_reading_ease: flesch_reading_ease,
          flesch_kincaid_grade: flesch_kincaid_grade
        }
      end

      def char_count(ignore_spaces: true)
        ignore_spaces ? text.delete(" ").length : text.length
      end

      def word_count(remove_punctuation: true)
        remove_punctuation ? words.size : text.split.size
      end

      def sentence_count
        text.scan(/(?<!\w\.\w.)(?<![A-Z][a-z]\.)(?<=\.|\?|!)(?=\s|$)/).size
      end

      def syllable_count
        return 0 if text.empty?

        words.sum { |word| hyphen_dictionary.visualise(word).count("-") + 1 }
      end

      def avg_sentence_length
        (word_count.to_f / sentence_count).round(1)
      rescue ZeroDivisionError
        0.0
      end

      def avg_syllables_per_word
        (syllable_count.to_f / word_count).round(1)
      rescue ZeroDivisionError
        0.0
      end

      def avg_letter_per_word
        (char_count.to_f / word_count).round(2)
      rescue ZeroDivisionError
        0.0
      end

      def avg_words_per_sentence
        (word_count.to_f / sentence_count).round(2)
      rescue ZeroDivisionError
        0.0
      end

      private

      def hyphen_dictionary
        raise NotImplementedError
      end

      def words
        @words ||= text.split
      end
    end
  end
end
