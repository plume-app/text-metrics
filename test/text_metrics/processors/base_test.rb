# frozen_string_literal: true

require "test_helper"

class TextMetrics::Processors::BaseTest < Minitest::Test
  def setup
    @very_easy_text = "Le chat dort. Il fait beau. Les oiseaux chantent dans les arbres. C'est l'été. Il n'y a pas de nuages."
    @processor = TextMetrics::Processors::Base.new(text: @very_easy_text)
  end

  def test_words_count
    count = @processor.words_count
    assert_equal 20, count
  end

  def test_characters_count
    count = @processor.characters_count
    assert_equal 83, count

    count = @processor.characters_count(ignore_spaces: false)
    assert_equal 102, count
  end

  def test_sentences_count
    count = @processor.sentences_count
    assert_equal 5, count
  end

  def test_sentences_count_with_punctuation_less_text
    text = "Il fait beau"
    @processor = TextMetrics::Processors::Base.new(text: text)
    assert_equal 1, @processor.sentences_count
  end

  def test_sentences_count_with_empty_text
    text = ""
    @processor = TextMetrics::Processors::Base.new(text: text)
    assert_equal 0, @processor.sentences_count
  end

  def test_letters_per_word_average
    avg = @processor.letters_per_word_average
    assert_equal 4.15, avg
  end

  def test_words_per_sentence_average
    avg = @processor.words_per_sentence_average
    assert_equal 4.0, avg
  end

  def test_levenshtein_distance
    processor = TextMetrics::Processors::Base.new(text: "hello world")
    assert_equal 100, processor.levenshtein_distance_from("hello world")
    assert (20..25).cover? processor.levenshtein_distance_from("bonjour monde")
    assert_equal 0, processor.levenshtein_distance_from("hello world", normalize: false)
    assert_equal 10, processor.levenshtein_distance_from("bonjour monde", normalize: false)
  end

  def test_levenshtein_distance_with_punctuation
    processor = TextMetrics::Processors::Base.new(text: "Il fait beau il y a du soleil et pas de nuages")
    assert_equal 0, processor.levenshtein_distance_from("Il fait beau il y a du soleil et pas de nuages", normalize: false)
  end
end
