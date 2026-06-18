# frozen_string_literal: true

require "text_metrics/processors/base"
require "yaml"

module TextMetrics
  module Processors
    class French < TextMetrics::Processors::Base
      SYLLABLE_EXCEPTIONS_PATH = File.join(GEM_PATH, "dictionaries/french_word_syllable_exceptions.yml").freeze
      EXCEPTIONS_LOAD_MUTEX = Mutex.new

      class << self
        # Syllable counts for the words the heuristic gets wrong (derived from Lexique),
        # loaded once and shared across all instances and threads. Lazy so requiring the gem
        # (or using only English/Levenshtein) doesn't pay the YAML load; the mutex guarantees
        # the file is parsed exactly once under concurrent first use, and the double check keeps
        # the common path lock-free. The result is frozen, so concurrent reads are safe.
        def syllable_exceptions
          return @syllable_exceptions if @syllable_exceptions

          EXCEPTIONS_LOAD_MUTEX.synchronize do
            @syllable_exceptions ||= YAML.load_file(SYLLABLE_EXCEPTIONS_PATH).freeze
          end
        end
      end

      # +with_syllable_exceptions+ is an internal toggle used by the dictionary-generation
      # scripts to run the bare heuristic; the public API always leaves it on.
      def initialize(text, language: :fr, with_syllable_exceptions: true)
        super(text, language: language)
        @with_syllable_exceptions = with_syllable_exceptions
      end

      # French Flesch Reading Ease — the Kandel-Moles (1958) adaptation:
      # 207 - 1.015 * (words / sentences) - 73.6 * (syllables / words).
      def flesch_reading_ease
        return 0.0 if words_count.zero?

        (207 - 1.015 * average_words_per_sentence - 73.6 * average_syllables_per_word).round(2)
      end

      private

      attr_reader :with_syllable_exceptions

      def count_syllables_in_word(word)
        if with_syllable_exceptions
          exceptions = self.class.syllable_exceptions
          return exceptions[word].to_i if exceptions.key?(word)
        end

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
