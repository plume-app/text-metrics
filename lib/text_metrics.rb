# frozen_string_literal: true

require "text_metrics/version"
require "text_metrics/configuration"
require "text_metrics/railtie" if defined?(Rails::Railtie)
require "text_metrics/levenshtein"
require "text_metrics/processors/american_english"
require "text_metrics/processors/french"

module TextMetrics
  class Error < StandardError; end

  DEFAULT_LANGUAGE = :en_us

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    private

    def reset_configuration!
      @configuration = Configuration.new
    end
  end

  PROCESSORS = {
    en_us: Processors::AmericanEnglish,
    fr: Processors::French
  }.freeze

  # Build an analyzer for +text+ in the given +language+ (:en_us or :fr).
  # Returns the language-specific processor, which exposes every metric and #to_h.
  def self.new(text, language: DEFAULT_LANGUAGE)
    language = resolve_language(language)
    PROCESSORS.fetch(language).new(text, language: language)
  end

  # Raw Levenshtein edit distance between two texts.
  def self.distance(text, other)
    Levenshtein.distance(text, other)
  end

  # Levenshtein similarity between two texts, as a 0–100 score (100.0 == identical).
  def self.similarity(text, other)
    Levenshtein.similarity(text, other)
  end

  # Coerce to a known language symbol, or raise a helpful error.
  # Handles nil, strings and symbols without leaking a NoMethodError.
  LANGUAGE_ALIASES = {en: :en_us}.freeze

  def self.resolve_language(language)
    resolved = language.to_s.to_sym
    resolved = LANGUAGE_ALIASES.fetch(resolved, resolved)
    return resolved if PROCESSORS.key?(resolved)

    raise Error, "Unknown language #{language.inspect}. Available languages: #{PROCESSORS.keys.join(", ")}"
  end
  private_class_method :resolve_language
end
