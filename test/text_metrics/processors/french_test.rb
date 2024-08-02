# frozen_string_literal: true

require "test_helper"

class TextMetrics::Processors::FrenchTest < Minitest::Test
  def setup
    @very_easy_text = "Le chat dort. Il fait beau. Les oiseaux chantent dans les arbres. C'est l'été. Il n'y a pas de nuages."
    @processor = TextMetrics::Processors::French.new(text: @very_easy_text)
  end

  def test_syllable_count
    count = @processor.syllable_count
    assert_equal 23, count
  end

  def test_avg_syllables_per_word
    avg = @processor.avg_syllables_per_word
    assert_equal 1.2, avg
  end

  def test_all
    all = @processor.all
    assert_equal 20, all[:word_count]
    assert_equal 83, all[:char_count]
    assert_equal 5, all[:sentence_count]
    assert_equal 23, all[:syllable_count]
    assert_equal 4.0, all[:avg_sentence_length]
    assert_equal 1.2, all[:avg_syllables_per_word]
    assert_equal 4.15, all[:avg_letter_per_word]
    assert_equal 4.0, all[:avg_words_per_sentence]
    assert_equal 100, all[:flesch_reading_ease]
    assert_equal 0.5, all[:flesch_kincaid_grade]
  end
end
