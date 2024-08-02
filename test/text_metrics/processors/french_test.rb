# frozen_string_literal: true

require "test_helper"

class TextMetrics::Processors::FrenchTest < Minitest::Test
  def setup
    @very_easy_text = "Le chat dort. Il fait beau. Les oiseaux chantent dans les arbres. C'est l'été. Il n'y a pas de nuages."
    @processor = TextMetrics::Processors::French.new(text: @very_easy_text)
  end

  def test_syllables_count
    count = @processor.syllables_count
    assert_equal 23, count
  end

  def test_syllables_per_word_average
    avg = @processor.syllables_per_word_average
    assert_equal 1.2, avg
  end

  def test_all
    all = @processor.all
    assert_equal 20, all[:words_count]
    assert_equal 83, all[:characters_count]
    assert_equal 5, all[:sentences_count]
    assert_equal 23, all[:syllables_count]
    assert_equal 4.0, all[:words_per_sentence_average]
    assert_equal 1.2, all[:syllables_per_word_average]
    assert_equal 4.15, all[:letters_per_word_average]
    assert_equal 4.0, all[:words_per_sentence_average]
    assert_equal 100, all[:flesch_reading_ease]
    assert_equal 0.5, all[:flesch_kincaid_grade]
  end
end
