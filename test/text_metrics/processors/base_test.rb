# frozen_string_literal: true

require "test_helper"

class TextMetrics::Processors::BaseTest < Minitest::Test
  def setup
    @very_easy_text = "Le chat dort. Il fait beau. Les oiseaux chantent dans les arbres. C'est l'été. Il n'y a pas de nuages."
    @processor = TextMetrics::Processors::Base.new(text: @very_easy_text)
  end

  def test_word_count
    count = @processor.word_count
    assert_equal 20, count
  end

  def test_char_count
    count = @processor.char_count
    assert_equal 83, count

    count = @processor.char_count(ignore_spaces: false)
    assert_equal 102, count
  end

  def test_sentence_count
    count = @processor.sentence_count
    assert_equal 5, count
  end

  def test_avg_sentence_length
    avg = @processor.avg_sentence_length
    assert_equal 4.0, avg
  end

  def test_avg_letter_per_word
    avg = @processor.avg_letter_per_word
    assert_equal 4.15, avg
  end

  def test_avg_words_per_sentence
    avg = @processor.avg_words_per_sentence
    assert_equal 4.0, avg
  end
end
