# frozen_string_literal: true

require "test_helper"

class TextMetrics::Processors::AmericanEnglishTest < Minitest::Test
  def setup
    @very_easy_text = "The cat is sleeping. It is beautiful. The birds are singing in the trees. It is the summer. There is no clouds."
    @processor = TextMetrics::Processors::AmericanEnglish.new(@very_easy_text)
  end

  def test_syllables_count
    count = @processor.syllables_count
    assert_equal 27, count
  end

  def test_syllables_per_word_average
    avg = @processor.syllables_per_word_average
    assert_equal 1.2, avg
  end

  def test_uses_cmudict_for_known_words
    assert_equal 3, TextMetrics::Processors::AmericanEnglish.new("beautiful").syllables_count
    assert_equal 1, TextMetrics::Processors::AmericanEnglish.new("the").syllables_count
    assert_equal 4, TextMetrics::Processors::AmericanEnglish.new("dictionary").syllables_count
  end

  def test_falls_back_to_hyphenation_for_unknown_words
    refute TextMetrics::Processors::AmericanEnglish.syllable_database.key?("flerbnozzle")

    processor = TextMetrics::Processors::AmericanEnglish.new("flerbnozzle")
    assert_operator processor.syllables_count, :>=, 1
  end

  def test_syllable_database_loads_once_under_concurrency
    klass = TextMetrics::Processors::AmericanEnglish
    klass.instance_variable_set(:@syllable_database, nil)

    databases = Array.new(20) { Thread.new { klass.syllable_database } }.map(&:value)

    assert_equal 1, databases.map(&:object_id).uniq.size, "expected the dictionary to load exactly once"
    assert_predicate databases.first, :frozen?
    assert_equal 3, databases.first["beautiful"]
  end

  def test_to_h
    all = @processor.to_h
    assert_equal 22, all[:words_count]
    assert_equal 90, all[:characters_count]
    assert_equal 5, all[:sentences_count]
    assert_equal 27, all[:syllables_count]
    assert_equal 1.2, all[:syllables_per_word_average]
    assert_equal 3.86, all[:letters_per_word_average]
    assert_equal 4.4, all[:words_per_sentence_average]
    assert_equal 98.54, all[:flesch_reading_ease]
    assert_equal 0.6, all[:flesch_kincaid_grade]
  end

  def test_to_h_keys_match_the_metrics_list
    assert_equal TextMetrics::Processors::Base::METRICS, @processor.to_h.keys
  end

  def test_to_h_with_trash_text
    @processor = TextMetrics::Processors::AmericanEnglish.new("bbbbhhhhhhhhhhhhhhhgggttrfter4zsezytrg6it5443z32")
    all = @processor.to_h
    assert_equal 0, all[:words_count]
    assert_equal 48, all[:characters_count]
    assert_equal 0, all[:sentences_count]
    assert_equal 0, all[:syllables_count]
    assert_equal 0.0, all[:syllables_per_word_average]
    assert_equal 0.0, all[:letters_per_word_average]
    assert_equal 0.0, all[:words_per_sentence_average]
    assert_equal 0.0, all[:characters_per_sentence_average]
    assert_equal 0.0, all[:flesch_reading_ease]
    assert_equal 0.0, all[:flesch_kincaid_grade]
  end

  def test_flesch_reading_ease_75
    text = "The sun was shining brightly in the clear blue sky. The children ran around the playground, laughing and playing with their friends. It was a perfect day for a picnic, and families spread out blankets on the grass, enjoying the warm weather."
    @processor = TextMetrics::Processors::AmericanEnglish.new(text)
    assert @processor.flesch_reading_ease >= 70
    assert @processor.flesch_reading_ease <= 80
  end

  # "As the day progressed, the sun began to dip below the horizon, casting long shadows across the park. The children reluctantly gathered their toys, knowing that it was time to head home. Their laughter gradually faded as the cool evening breeze picked up, signaling the end of a pleasant afternoon."
  def test_flesch_reading_ease_65
    text = "As the day progressed, the sun began to dip below the horizon, casting long shadows across the park. The children reluctantly gathered their toys, knowing that it was time to head home. Their laughter gradually faded as the cool evening breeze picked up, signaling the end of a pleasant afternoon."
    @processor = TextMetrics::Processors::AmericanEnglish.new(text)
    assert @processor.flesch_reading_ease >= 60
    assert @processor.flesch_reading_ease <= 70
  end

  def test_flesch_reading_ease_40
    text = "The gradual transition from day to night brings a sense of calm and reflection. As the sun sets, the world seems to pause momentarily, allowing individuals a brief respite from their daily activities. This period, often referred to as twilight, is marked by a unique interplay of light and shadow, creating an atmosphere that is both serene and contemplative."
    @processor = TextMetrics::Processors::AmericanEnglish.new(text)
    assert @processor.flesch_reading_ease >= 40
    assert @processor.flesch_reading_ease <= 60
  end

  def test_flesch_reading_ease_25
    text = "The juxtaposition of light and dark during twilight creates a transient, liminal space, often imbued with a sense of both anticipation and nostalgia. This temporal interstice, though brief, has been the subject of extensive literary and artistic exploration, as it encapsulates the ephemeral nature of existence itself."
    @processor = TextMetrics::Processors::AmericanEnglish.new(text)
    assert @processor.flesch_reading_ease >= 20
    assert @processor.flesch_reading_ease <= 30
  end

  def test_flesch_reading_ease_10
    text = "The dichotomous nature of twilight, wherein diurnal and nocturnal elements coexist in a fleeting equilibrium, offers a fertile ground for metaphysical inquiry. This ephemeral period, often characterized by a sense of transience and impermanence, serves as a poignant reminder of the inexorable passage of time and the transient nature of human existence"
    @processor = TextMetrics::Processors::AmericanEnglish.new(text)
    assert @processor.flesch_reading_ease <= 10
  end
end
