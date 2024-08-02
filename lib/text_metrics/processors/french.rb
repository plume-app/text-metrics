# frozen_string_literal: true

require "text_metrics/processors/base"

module TextMetrics
  module Processors
    class French < TextMetrics::Processors::Base
      def flesch_reading_ease
        sentence_length = avg_sentence_length
        syllables_per_word = avg_syllables_per_word
        flesch = 206.835 - 1.015 * sentence_length - 73.6 * syllables_per_word

        [100, flesch.round(2)].min
      end

      def flesch_kincaid_grade
        sentence_length = avg_sentence_length
        syllables_per_word = avg_syllables_per_word
        flesch = (0.55 * sentence_length) + (11.76 * syllables_per_word) - 15.79

        flesch.round(1)
      end

      private

      def hyphen_dictionary
        @hyphen_dictionary ||= Text::Hyphen.new(language: "fr", left: 0, right: 0)
      end
    end
  end
end
