# frozen_string_literal: true

require "test_helper"

class TextMetricsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TextMetrics::VERSION
  end

  def test_loadable_by_the_hyphenated_gem_name
    # Bundler auto-requires the gem name as-is (`require "text-metrics"`); the shim must load.
    require "text-metrics"
    assert defined?(TextMetrics::VERSION)
  end

  def test_defaults_to_american_english
    metrics = TextMetrics.new("Hello world")
    assert_kind_of TextMetrics::Processors::AmericanEnglish, metrics
    assert_equal :en_us, metrics.language
  end

  def test_builds_a_french_processor
    metrics = TextMetrics.new("Bonjour", language: :fr)
    assert_kind_of TextMetrics::Processors::French, metrics
    assert_equal :fr, metrics.language
  end

  def test_accepts_a_string_language
    metrics = TextMetrics.new("Bonjour", language: "fr")
    assert_kind_of TextMetrics::Processors::French, metrics
  end

  def test_unknown_language_raises_a_helpful_error
    error = assert_raises(TextMetrics::Error) do
      TextMetrics.new("Hello", language: :es)
    end
    assert_includes error.message, "es"
    assert_includes error.message, "en_us"
  end

  def test_nil_language_raises_a_helpful_error
    error = assert_raises(TextMetrics::Error) do
      TextMetrics.new("Hello", language: nil)
    end
    assert_includes error.message, "en_us"
  end

  def test_text_reflects_what_is_analyzed
    metrics = TextMetrics.new("hello    world")
    assert_equal "hello world", metrics.text
  end

  def test_distance_helper
    assert_equal 0, TextMetrics.distance("hello", "hello")
    assert_equal 1, TextMetrics.distance("hello", "hallo")
  end

  def test_similarity_helper
    assert_equal 100.0, TextMetrics.similarity("hello", "hello")
    assert TextMetrics.similarity("hello", "world") < 100.0
  end
end
