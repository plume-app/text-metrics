# frozen_string_literal: true

require "test_helper"

class TextMetrics::Processors::FrenchTest < Minitest::Test
  def setup
    @very_easy_text = "Le chat dort. Il fait beau. Les oiseaux chantent dans les arbres. C'est l'été. Il n'y a pas de nuages."
    @processor = TextMetrics::Processors::French.new(text: @very_easy_text)
  end

  def test_syllables_per_word_average
    avg = @processor.syllables_per_word_average
    assert_equal 1.3, avg
  end

  def test_all
    all = @processor.all
    assert_equal 20, all[:words_count]
    assert_equal 83, all[:characters_count]
    assert_equal 5, all[:sentences_count]
    assert_equal 25, all[:syllables_count]
    assert_equal 4.0, all[:words_per_sentence_average]
    assert_equal 1.3, all[:syllables_per_word_average]
    assert_equal 4.15, all[:letters_per_word_average]
    assert_equal 4.0, all[:words_per_sentence_average]
    assert all[:flesch_reading_ease] >= 90
    assert all[:flesch_reading_ease] <= 100
    assert_equal 1.7, all[:flesch_kincaid_grade]
  end

  def test_word_count
    text = "Je suis 4 billevesées 😆 ♥️!"
    @processor = TextMetrics::Processors::French.new(text: text)
    assert_equal 3, @processor.words_count

    text = "Ici, 3 termes"
    @processor = TextMetrics::Processors::French.new(text: text)
    assert_equal 2, @processor.words_count

    text = "Dix mots à moi ; dans cette phrase en tout cas."
    @processor = TextMetrics::Processors::French.new(text: text)
    assert_equal 10, @processor.words_count

    text = "J'ai une apostrophe, et pourtant sept mots."
    @processor = TextMetrics::Processors::French.new(text: text)
    assert_equal 7, @processor.words_count

    text = "eux-mêmes ne sont pas des mots"
    @processor = TextMetrics::Processors::French.new(text: text)
    assert_equal 6, @processor.words_count
  end

  def test_syllables_count
    assert_equal 25, @processor.syllables_count
  end

  def test_syllables_count_with_corpus
    words = YAML.load_file("lib/text_metrics/dictionnaries/french_word_syllable_database.yml")

    count = 0
    errors = []
    words.to_a.sample(1000).each do |row|
      word, syllables_count = row
      @processor = TextMetrics::Processors::French.new(text: word)
      count += 1
      errors << {word => syllables_count} unless syllables_count.to_i == @processor.syllables_count
    end

    puts errors
    assert_equal 0, errors.size
  end

  def test_poly_syllabes_count
    text = "immeubles"
    @processor = TextMetrics::Processors::French.new(text: text)
    assert_equal 1, @processor.poly_syllabes_count

    text = "arbre"
    @processor = TextMetrics::Processors::French.new(text: text)
    assert_equal 0, @processor.poly_syllabes_count
  end

  def test_flesch_reading_ease_95
    text = "Le chat dort. Il fait beau. Les oiseaux chantent dans les arbres. C'est l'été. Il n'y a pas de nuages."
    @processor = TextMetrics::Processors::French.new(text: text)

    assert @processor.flesch_reading_ease >= 90
    assert @processor.flesch_reading_ease <= 100
  end

  def test_flesch_reading_ease_75
    text = "Marie aime lire des livres. Elle va souvent à la bibliothèque pour en emprunter. Son genre préféré est le roman d'aventure. Elle lit tous les soirs avant de dormir."
    @processor = TextMetrics::Processors::French.new(text: text)

    assert @processor.flesch_reading_ease >= 70
    assert @processor.flesch_reading_ease <= 80
  end

  def test_flesch_reading_ease_65
    text = "La pollution de l'air est un problème majeur dans les grandes villes. Elle est causée par les gaz d'échappement des voitures et les usines. Cette pollution peut avoir des effets néfastes sur la santé des habitants et sur l'environnement."
    @processor = TextMetrics::Processors::French.new(text: text)

    assert @processor.flesch_reading_ease >= 60
    assert @processor.flesch_reading_ease <= 70
  end

  def test_flesch_reading_ease_40
    text = "La théorie de la relativité restreinte, formulée par Albert Einstein en 1905, postule que les lois de la physique sont invariantes dans tous les référentiels inertiels et que la vitesse de la lumière dans le vide est constante, indépendamment du mouvement de la source ou de l'observateur. Cette théorie a profondément modifié notre compréhension de l'espace et du temps."
    @processor = TextMetrics::Processors::French.new(text: text)

    assert @processor.flesch_reading_ease >= 35
    assert @processor.flesch_reading_ease <= 45
  end

  def test_flesch_reading_ease_30
    text = "L'épigénétique est un domaine de la biologie qui étudie les modifications de l'expression des gènes sans changement de la séquence d'ADN. Ces modifications peuvent être influencées par l'environnement et le mode de vie, et peuvent parfois être transmises aux générations suivantes."
    @processor = TextMetrics::Processors::French.new(text: text)

    assert @processor.flesch_reading_ease >= 25
    assert @processor.flesch_reading_ease <= 35
  end

  def test_flesch_reading_ease_25
    text = "La nature dichotomique du crépuscule, où les éléments diurnes et nocturnes coexistent dans un équilibre fugace, offre un terrain fertile pour l'enquête métaphysique. Cette période éphémère, souvent caractérisée par un sentiment de transience et d'impermanence, sert de rappel poignant du passage inexorable du temps et de la nature éphémère de l'existence humaine."
    @processor = TextMetrics::Processors::AmericanEnglish.new(text: text)

    assert @processor.flesch_reading_ease <= 30
  end
end
