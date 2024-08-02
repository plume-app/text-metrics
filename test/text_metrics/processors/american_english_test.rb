# frozen_string_literal: true

require "test_helper"

class TextMetrics::Processors::AmericanEnglishTest < Minitest::Test
  def setup
    @very_easy_text = "The cat is sleeping. It is beautiful. The birds are singing in the trees. It is the summer. There is no clouds."
    @processor = TextMetrics::Processors::AmericanEnglish.new(text: @very_easy_text)
  end

  def test_syllable_count
    count = @processor.syllable_count
    assert_equal 28, count
  end

  def test_avg_syllables_per_word
    avg = @processor.avg_syllables_per_word
    assert_equal 1.3, avg
  end

  def test_all
    all = @processor.all
    assert_equal 22, all[:word_count]
    assert_equal 90, all[:char_count]
    assert_equal 5, all[:sentence_count]
    assert_equal 28, all[:syllable_count]
    assert_equal 4.4, all[:avg_sentence_length]
    assert_equal 1.3, all[:avg_syllables_per_word]
    assert_equal 4.09, all[:avg_letter_per_word]
    assert_equal 4.4, all[:avg_words_per_sentence]
    assert_equal 92.39, all[:flesch_reading_ease]
    assert_equal 1.5, all[:flesch_kincaid_grade]
  end
end
