# frozen_string_literal: true

require "text_metrics/processors/base"
require "yaml"

module TextMetrics
  module Processors
    class French < TextMetrics::Processors::Base
      GEM_PATH = File.dirname(__FILE__, 2).freeze
      SYLLABLE_EXCEPTIONS_PATH = File.join(GEM_PATH, "dictionnaries/french_word_syllable_exceptions.yml").freeze
      SYLLABLE_EXCEPTIONS = YAML.load_file(SYLLABLE_EXCEPTIONS_PATH).freeze

      def flesch_reading_ease
        sentence_length = words_per_sentence_average
        syllables_per_word = syllables_per_word_average
        flesch = 206.835 - 1.015 * sentence_length - 73.6 * syllables_per_word

        [100.0, flesch.round(2)].min
      end

      def flesch_kincaid_grade
        sentence_length = words_per_sentence_average
        syllables_per_word = syllables_per_word_average
        flesch = (0.55 * sentence_length) + (11.76 * syllables_per_word) - 15.79

        [1.0, flesch.round(1)].max
      end

      private

      def count_syllables_in_word(word)
        return SYLLABLE_EXCEPTIONS[word].to_i if with_syllable_exceptions && SYLLABLE_EXCEPTIONS.key?(word)

        word = word.downcase.gsub(/[^a-zàâäéèêëîïôöùûüç]/, "")

        # Define vowel patterns including accents
        vowels = "aàâeéèêëiîïoôöuùûüy"

        # Remove final silent 'e' or 'es' unless the word is a single letter
        word.gsub!(/(e|es|ent)$/, "") unless word.size == 1

        # Handle special case for words ending with a consonant followed by 'r' (e.g., 'arbre')
        if /[^aeiouy]r$/.match?(word)
          word += "e" # Temporarily treat the final 'r' as part of a vowel sound for syllable counting
        end

        # Split the word into parts based on vowel-consonant transitions
        parts = word.scan(/[^#{vowels}]*[#{vowels}]+/)

        # Count the syllables based on vowel groups in each part
        parts.sum { |part| part.scan(/[#{vowels}]+/).size }
      end
    end
  end
end
