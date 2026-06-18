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

  def test_text_is_whitespace_normalized
    assert_equal "a b c", TextMetrics::Processors::Base.new("a   b    c").text
  end
end
