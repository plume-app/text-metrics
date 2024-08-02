# frozen_string_literal: true

require "test_helper"

class TextMetrics::Processors::AmericanEnglishTest < Minitest::Test
  def setup
    @very_easy_text = "The cat is sleeping. It is beautiful. The birds are singing in the trees. It is the summer. There is no clouds."
    @processor = TextMetrics::Processors::AmericanEnglish.new(text: @very_easy_text)
  end

  def test_syllables_count
    count = @processor.syllables_count
    assert_equal 28, count
  end

  def test_syllables_per_word_average
    avg = @processor.syllables_per_word_average
    assert_equal 1.3, avg
  end

  def test_all
    all = @processor.all
    assert_equal 22, all[:words_count]
    assert_equal 90, all[:characters_count]
    assert_equal 5, all[:sentences_count]
    assert_equal 28, all[:syllables_count]
    assert_equal 4.4, all[:words_per_sentence_average]
    assert_equal 1.3, all[:syllables_per_word_average]
    assert_equal 4.09, all[:letters_per_word_average]
    assert_equal 4.4, all[:words_per_sentence_average]
    assert_equal 92.39, all[:flesch_reading_ease]
    assert_equal 1.5, all[:flesch_kincaid_grade]
  end
end
