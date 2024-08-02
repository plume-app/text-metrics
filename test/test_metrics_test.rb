# frozen_string_literal: true

require "test_helper"

class TextMetricsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TextMetrics::VERSION
  end

  def test_count_french_words
    text_metrics = TextMetrics.new(text: "Bonjour", language: "fr")
    assert_equal text_metrics.word_count, 1
  end

  def test_count_american_english_words
    text_metrics = TextMetrics.new(text: "Hello world", language: "en_US")
    assert_equal text_metrics.word_count, 2
  end
end
