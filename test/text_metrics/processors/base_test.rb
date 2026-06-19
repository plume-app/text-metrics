# frozen_string_literal: true

require "test_helper"

class TextMetrics::Processors::BaseTest < Minitest::Test
  def setup
    @very_easy_text = "Le chat dort. Il fait beau. Les oiseaux chantent dans les arbres. C'est l'été. Il n'y a pas de nuages."
    @processor = TextMetrics::Processors::Base.new(@very_easy_text)
  end

  def test_words_count
    assert_equal 20, @processor.words_count
  end

  def test_characters_count
    assert_equal 83, @processor.characters_count
    assert_equal 102, @processor.characters_count(ignore_spaces: false)
  end

  def test_sentences_count
    assert_equal 5, @processor.sentences_count
  end

  def test_sentences_count_with_punctuation_less_text
    processor = TextMetrics::Processors::Base.new("Il fait beau")
    assert_equal 1, processor.sentences_count
  end

  def test_sentences_count_with_empty_text
    processor = TextMetrics::Processors::Base.new("")
    assert_equal 0, processor.sentences_count
  end

  def test_sentences_count_with_nil_text
    processor = TextMetrics::Processors::Base.new(nil)
    assert_equal 0, processor.sentences_count
  end

  def test_letters_per_word_average
    assert_equal 3.75, @processor.letters_per_word_average
  end

  def test_words_per_sentence_average
    assert_equal 4.0, @processor.words_per_sentence_average
  end

  def test_punctuation_count
    assert_equal 5, @processor.punctuation_count
  end

  def test_long_words_count
    # "oiseaux" (7) and "chantent" (8) are the only words longer than six characters.
    assert_equal 2, @processor.long_words_count
  end

  def test_type_token_ratio
    # 20 words, two repeats ("les", "il") => 18 distinct / 20.
    assert_equal 0.9, @processor.type_token_ratio
  end

  def test_type_token_ratio_with_empty_text
    assert_equal 0.0, TextMetrics::Processors::Base.new("").type_token_ratio
  end

  def test_automated_readability_index
    # 4.71 * 83 / 20 + 0.5 * (20 / 5) - 21.43 ≈ 0.1
    assert_equal 0.1, @processor.automated_readability_index
  end

  def test_automated_readability_index_with_empty_text
    assert_equal 0.0, TextMetrics::Processors::Base.new("").automated_readability_index
  end

  def test_reading_time
    # 20 words at the default 200 wpm => 0.1 minutes.
    assert_equal 0.1, @processor.reading_time
  end

  def test_reading_time_accepts_a_custom_wpm
    assert_equal 0.2, @processor.reading_time(wpm: 100)
  end

  def test_reading_time_with_empty_text
    assert_equal 0.0, TextMetrics::Processors::Base.new("").reading_time
  end

  def test_text_is_whitespace_normalized
    assert_equal "a b c", TextMetrics::Processors::Base.new("a   b    c").text
  end
end
