# frozen_string_literal: true

require "test_helper"

class TextMetricsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TextMetrics::VERSION
  end

  def test_french_processor
    text_metrics = TextMetrics.new(text: "Bonjour", language: "fr")
    assert text_metrics.text_metrics_processor.is_a?(TextMetrics::Processors::French)
  end

  def test_american_english_processor
    text_metrics = TextMetrics.new(text: "Hello world", language: "en_US")
    assert text_metrics.text_metrics_processor.is_a?(TextMetrics::Processors::AmericanEnglish)
  end
end
