# frozen_string_literal: true

require "text_metrics/processors/base"

module TextMetrics
  module Processors
    class AmericanEnglish < TextMetrics::Processors::Base
      def flesch_reading_ease
        sentence_length = words_per_sentence_average
        syllables_per_word = syllables_per_word_average
        flesch = 206.835 - 1.015 * sentence_length - 84.6 * syllables_per_word

        [100, flesch.round(2)].min
      end

      def flesch_kincaid_grade
        sentence_length = words_per_sentence_average
        syllables_per_word = syllables_per_word_average
        flesch = 0.39 * sentence_length + 11.8 * syllables_per_word - 15.59
        flesch.round(1)
      end

      private

      def count_syllables_in_word(word)
        hyphen_dictionary.visualise(word).count("-") + 1
      end

      def hyphen_dictionary
        @hyphen_dictionary ||= Text::Hyphen.new(language: "en_us", left: 0, right: 0)
      end
    end
  end
end
