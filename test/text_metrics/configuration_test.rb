# frozen_string_literal: true

require "test_helper"

class TextMetrics::ConfigurationTest < Minitest::Test
  def setup
    TextMetrics.send(:reset_configuration!)
  end

  def teardown
    TextMetrics.send(:reset_configuration!)
  end

  def test_default_wpm
    assert_equal 200, TextMetrics.configuration.wpm
  end

  def test_configure_wpm
    TextMetrics.configure { |c| c.wpm = 100 }
    assert_equal 100, TextMetrics.configuration.wpm
  end

  def test_reading_time_uses_configured_wpm
    TextMetrics.configure { |c| c.wpm = 100 }
    processor = TextMetrics::Processors::Base.new("word " * 100)
    assert_equal 1.0, processor.reading_time
  end

  def test_reading_time_inline_override_takes_precedence
    TextMetrics.configure { |c| c.wpm = 100 }
    processor = TextMetrics::Processors::Base.new("word " * 200)
    assert_equal 0.5, processor.reading_time(wpm: 400)
  end
end
