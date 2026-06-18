# frozen_string_literal: true

require "text_metrics/version"
require "text_metrics/levenshtein"
require "text_metrics/processors/american_english"
require "text_metrics/processors/french"

module TextMetrics
  class Error < StandardError; end

  DEFAULT_LANGUAGE = :en_us

  PROCESSORS = {
    en_us: Processors::AmericanEnglish,
    fr: Processors::French
  }.freeze

  # Build an analyzer for +text+ in the given +language+ (:en_us or :fr).
  # Returns the language-specific processor, which exposes every metric and #to_h.
  def self.new(text, language: DEFAULT_LANGUAGE)
    processor_for(language).new(text, language: language.to_sym)
  end

  # Raw Levenshtein edit distance between two texts.
  def self.distance(text, other)
    Levenshtein.distance(text, other)
  end

  # Levenshtein similarity between two texts, as a 0–100 score (100.0 == identical).
  def self.similarity(text, other)
    Levenshtein.similarity(text, other)
  end

  def self.processor_for(language)
    PROCESSORS.fetch(language.to_sym) do
      raise Error, "Unknown language #{language.inspect}. Available languages: #{PROCESSORS.keys.join(", ")}"
    end
  end
  private_class_method :processor_for
end
