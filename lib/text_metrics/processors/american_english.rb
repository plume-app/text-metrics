# frozen_string_literal: true

require "text_metrics/processors/base"

module TextMetrics
  module Processors
    class AmericanEnglish < TextMetrics::Processors::Base
      SYLLABLE_DATABASE_PATH = File.join(GEM_PATH, "dictionaries/english_word_syllable_database.txt").freeze
      DATABASE_LOAD_MUTEX = Mutex.new

      class << self
        # CMU Pronouncing Dictionary syllable counts, loaded once and shared across all
        # instances and threads. Lazy so requiring the gem (or using only
        # French/Levenshtein) doesn't pay the load cost; the mutex guarantees the file is
        # parsed exactly once under concurrent first use, and the double check keeps the
        # common path lock-free. The result is frozen, so concurrent reads are safe.
        def syllable_database
          return @syllable_database if @syllable_database

          DATABASE_LOAD_MUTEX.synchronize do
            @syllable_database ||= load_syllable_database
          end
        end

        private

        def load_syllable_database
          database = {}
          File.foreach(SYLLABLE_DATABASE_PATH) do |line|
            word, count = line.split(" ", 2)
            database[word] = count.to_i
          end
          database.freeze
        end
      end

      def initialize(text, language: :en_us)
        super
      end

      def flesch_reading_ease
        return 0.0 if words_count.zero?

        (206.835 - 1.015 * average_words_per_sentence - 84.6 * average_syllables_per_word).round(2)
      end

      private

      # CMUdict is the source of truth; fall back to hyphenation for out-of-vocabulary words.
      def count_syllables_in_word(word)
        self.class.syllable_database.fetch(word.downcase) { hyphenated_syllable_count(word) }
      end

      def hyphenated_syllable_count(word)
        hyphen_dictionary.visualise(word).count("-") + 1
      end

      def hyphen_dictionary
        @hyphen_dictionary ||= Text::Hyphen.new(language: "en_us", left: 0, right: 0)
      end
    end
  end
end
