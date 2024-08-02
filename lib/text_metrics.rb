# frozen_string_literal: true

require "text_metrics/version"
require "text_metrics/processors/french"
require "text_metrics/processors/american_english"
require "forwardable"

module TextMetrics
  class Error < StandardError; end

  class TextMetrics
    extend Forwardable
    def_delegators :text_metrics_processor, :words_count, :characters_count, :syllables_count,
      :sentences_count, :words_per_sentence_average, :syllables_per_word_average,
      :letters_per_word_average, :words_per_sentence_average, :characters_per_sentence_average,
      :flesch_reading_ease, :flesch_kincaid_grade, :all

    PROCESSORS = {
      "fr" => Processors::French,
      "en_US" => Processors::AmericanEnglish
    }

    attr_reader :text, :language, :text_metrics_processor

    def initialize(text:, language: "en_US")
      @text = text
      @language = language
      @text_metrics_processor = PROCESSORS[language].new(text: text)
    end

    private

    def processor_for(language)
      PROCESSORS[language] || raise("Unknown language: #{language}, available languages: #{PROCESSORS.keys}")
    end
  end

  def self.new(text:, language: "en_US")
    TextMetrics.new(text: text, language: language)
  end
end
