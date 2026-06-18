# frozen_string_literal: true

require "test_helper"

class TextMetrics::LevenshteinTest < Minitest::Test
  def test_distance_for_identical_strings
    assert_equal 0, TextMetrics::Levenshtein.distance("hello world", "hello world")
  end

  def test_distance_for_different_strings
    assert_equal 10, TextMetrics::Levenshtein.distance("hello world", "bonjour monde")
    assert_equal 1, TextMetrics::Levenshtein.distance("hello", "hallo")
  end

  def test_distance_is_case_sensitive
    assert_equal 1, TextMetrics::Levenshtein.distance("Hello", "hello")
  end

  def test_distance_with_empty_strings
    assert_equal 5, TextMetrics::Levenshtein.distance("", "hello")
    assert_equal 5, TextMetrics::Levenshtein.distance("hello", "")
    assert_equal 0, TextMetrics::Levenshtein.distance("", "")
  end

  def test_similarity_for_identical_strings
    assert_equal 100.0, TextMetrics::Levenshtein.similarity("hello world", "hello world")
  end

  def test_similarity_for_different_strings
    assert (20..25).cover? TextMetrics::Levenshtein.similarity("hello world", "bonjour monde")
  end

  def test_similarity_with_empty_strings
    assert_equal 100.0, TextMetrics::Levenshtein.similarity("", "")
    assert_equal 0.0, TextMetrics::Levenshtein.similarity("", "hello")
  end
end
