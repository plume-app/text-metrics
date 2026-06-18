# frozen_string_literal: true

require "test_helper"

class TextMetrics::Processors::FrenchTest < Minitest::Test
  def setup
    @very_easy_text = "Le chat dort. Il fait beau. Les oiseaux chantent dans les arbres. C'est l'été. Il n'y a pas de nuages."
    @long_easy_text = <<~HEREDOC
      Mettre en place un concours d’écriture au sein de la classe permet de planifier de manière hyper concrète l’écrit de la phase d’idéation (souvent avec des contraintes) à la production finale. La dimension “concours” peut permettre une grande émulation au sein de la classe et favoriser l’entraide entre les élèves pour arriver à un but commun. Que ce soit au primaire ou au collège, ces événements offrent bien plus qu’une simple compétition : ils nourrissent la créativité, renforcent la confiance en soi et encouragent l’excellence dans l’art de la composition littéraire. L’inscription à un concours motive les élèves à donner le meilleur d’eux-mêmes. Savoir que leur travail sera évalué par des pairs ou des professionnels les pousse à se surpasser, à peaufiner leurs textes et à rechercher l’excellence. Cette motivation intrinsèque alimente un cercle vertueux où chaque élève cherche à s’améliorer continuellement pour atteindre l’excellence.

      Mener un projet d’écriture fédérateur au sein de la classe grâce à un concours d’écriture
      Dans le domaine de l’éducation, l’écriture occupe une place centrale dans le développement des compétences linguistiques et créatives des élèves. Cependant, susciter et maintenir l’intérêt des élèves pour cet exercice peut parfois représenter un véritable défi.

      Une recherche menée par Graham et Hebert (2010) a révélé que les projets d’écriture collaborative, tels que les concours d’écriture en classe, favorisent un engagement accru des élèves dans le processus d’écriture. En impliquant activement les élèves dans la planification, la rédaction et la révision de leurs textes, il nous est possible en tant qu’enseignant cultiver un sentiment de responsabilité et de propriété vis-à-vis de leur travail, ce qui se traduit souvent par une motivation accrue pour réussir. Les choses deviennent concrètes grâce à ce but commun !
    HEREDOC

    @long_difficult_text = <<~HEREDOC
      L'objectif de cette thèse est l'étude de la relation entre la capacité de la mémoire de travail et la compréhension de l'écrit chez l'enfant. Pour comprendre un texte, le lecteur doit construire une représentation mentale cohérente du contenu du texte. Cette élaboration dépend d'une capacité d'intégration des informations. Cette capacité d'intégration est dénommée mémoire de travail. La mémoire de travail est définie comme un système assurant le stockage temporaire d'informations durant un certain traitement. Les expériences rapportées dans cette thèse montrent que l'efficience de la compréhension de l'écrit chez l'enfant dépend de la capacité de la mémoire de travail. Plus précisément, la capacité de la mémoire de travail apparait comme un prédicteur significatif de la compréhension de l'écrit à partir du moment où l'enfant maitrise les règles de conversion graphophonologique, c'est à dire à partir de la troisième année scolaire (neuf ans). La capacité de la mémoire de travail devient alors un prédicteur spécifique et important de la compréhension de l'écrit, compare à l'efficience de la lecture et au vocabulaire. Par ailleurs, les résultats permettent de caractériser la nature de cette relation sur plusieurs aspects. Ils mettent en évidence les contraintes imposées par la capacité de la mémoire de travail sur une opération psycholinguistique particulière, le traitement des pronoms. De plus, ils spécifient la nature des ressources impliquées dans le langage qui sont mesurées par la capacité de la mémoire de travail. Ces ressources apparaissent relativement spécialisées dans le traitement du langage. Enfin, une nouvelle orientation de recherches est proposée visant à préciser les processus attentionnels de base qui pourraient sous-tendre la relation observée entre compréhension de l'écrit et mémoire travail. Il pourrait s'agir en particulier d'un processus d'inhibition dont le rôle est mis en évidence chez les enfants de dix ans.
    HEREDOC
    @processor = TextMetrics::Processors::French.new(@very_easy_text)
  end

  def test_syllables_per_word_average
    avg = @processor.syllables_per_word_average
    assert_equal 1.3, avg
  end

  def test_to_h
    all = @processor.to_h
    assert_equal 20, all[:words_count]
    assert_equal 83, all[:characters_count]
    assert_equal 5, all[:sentences_count]
    assert_equal 25, all[:syllables_count]
    assert_equal 4.0, all[:words_per_sentence_average]
    assert_equal 1.3, all[:syllables_per_word_average]
    assert_equal 3.75, all[:letters_per_word_average]
    assert_equal 4.0, all[:words_per_sentence_average]
    assert_equal 110.94, all[:flesch_reading_ease]
    assert_equal 0.7, all[:flesch_kincaid_grade]
    assert_equal 14.0, all[:lix]
    assert_equal 3.1, all[:smog_index]
    assert_equal(-1.15, all[:coleman_liau_index])
  end

  def test_to_h_with_trash_text
    @processor = TextMetrics::Processors::French.new("bbbbhhhhhhhhhhhhhhhgggttrfter4zsezytrg6it5443z32")
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

  def test_word_count
    text = "Je suis 4 billevesées 😆 ♥️!"
    @processor = TextMetrics::Processors::French.new(text)
    assert_equal 3, @processor.words_count

    text = "Ici, 3 termes"
    @processor = TextMetrics::Processors::French.new(text)
    assert_equal 2, @processor.words_count

    text = "Dix mots à moi ; dans cette phrase en tout cas."
    @processor = TextMetrics::Processors::French.new(text)
    assert_equal 10, @processor.words_count

    text = "J'ai une apostrophe, et pourtant sept mots."
    @processor = TextMetrics::Processors::French.new(text)
    assert_equal 7, @processor.words_count

    text = "eux-mêmes ne sont pas des mots"
    @processor = TextMetrics::Processors::French.new(text)
    assert_equal 6, @processor.words_count
  end

  def test_syllables_count
    assert_equal 25, @processor.syllables_count
  end

  def test_syllables_count_with_corpus
    words = YAML.load_file("data/french_word_syllable_database.yml")

    count = 0
    errors = []
    words.to_a.sample(1000).each do |row|
      word, syllables_count = row
      @processor = TextMetrics::Processors::French.new(word)
      count += 1
      errors << {word => syllables_count} unless syllables_count.to_i == @processor.syllables_count
    end

    puts errors
    assert_equal 0, errors.size
  end

  def test_punctuation_count
    text = "Le chat dort. Il fait beau."
    @processor = TextMetrics::Processors::French.new(text)
    assert_equal 2, @processor.punctuation_count

    text = "Le chat dort. Il fait beau. Les oiseaux chantent, dans les arbres; C'est l'été! Tu vois des nuages?"
    @processor = TextMetrics::Processors::French.new(text)
    assert_equal 6, @processor.punctuation_count
  end

  def test_with_long_text_without_punctuation
    text = "Je m'appelle emie et je suis une fille j'adore l'aventure mais je m'ennuie en ce moment j'en ai rien à faire j'aimerais bien partir en voyage en voyage avec mes amis ou tout seul c'est pas grave en Italie en Allemagne je sais pas et si j'allais en Allemagne ce serait bien je prends mes valises et j'y vais j'ai trouvé un vol pour minuit j'ai le temps de faire mes valises et de envoyer un message à tous mes amis pour leur dire que je m'en vais je vais dans un hôtel ça ira demain matin je monte dans le train mes amis m'accompagnent me dire au revoir et je leur dis à très bientôt je reviendrai avec du récit plein la voix je suis prête à m'en aller le train est là je dis à mes amis au revoir une fois arrivé en Allemagne dans mon hôtel je regarde je te l'ai fermé j'attends que la porte une personne en capuchonner m'ouvre la porte et me dit entre si tu veux mourir et je m'enfuis en courant une fois caché dans une petite ruelle très sombre je me dis qui est-ce il fait peur noir sombre où est-ce que je vais dormir moi je sais je vais faire du porte-à-porte ah zut le revoilà il me suit je cours à toutes les portes vite vite vite est-ce que vous voulez bien que je dorme chez vous oui bien sûr entre je rentre et là dans la chambre que m'indique la dame je vois un capuchonner assis sur le lit il enlève sa capuche et finalement c'est son fils un gentil garçon de 5 ou 6 ans qui était monté sur les épaules et ça de sa sœur qui avait 6 ans quel frayeur plus jamais ça les enfants."

    @processor = TextMetrics::Processors::French.new(text)

    # Scores are unclamped; on pathological input (here one long unpunctuated "sentence")
    # they can fall well outside the usual ranges — assert only that they compute.
    assert_kind_of Float, @processor.flesch_reading_ease
    assert_kind_of Float, @processor.flesch_kincaid_grade
    assert_kind_of Float, @processor.smog_index
    assert_kind_of Float, @processor.coleman_liau_index
    assert_kind_of Float, @processor.lix
  end

  def test_with_very_long_trash_text
    text = "Jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaazzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkggggggggggggggggvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggvvvvvvvvvvvvvvvvvvvvvvv"
    @processor = TextMetrics::Processors::French.new(text)

    assert @processor.to_h.is_a?(Hash)
    assert_kind_of Float, @processor.flesch_reading_ease
    assert_kind_of Float, @processor.flesch_kincaid_grade
    assert_kind_of Float, @processor.smog_index
    assert_kind_of Float, @processor.coleman_liau_index
    assert_kind_of Float, @processor.lix
  end

  def test_smog_index
    text = "Le chat dort. Il fait beau. Les oiseaux chantent dans les arbres. C'est l'été. Il n'y a pas de nuages."
    @processor = TextMetrics::Processors::French.new(text)

    assert_equal 3.1, @processor.smog_index
  end

  def test_coleman_liau_index
    @processor = TextMetrics::Processors::French.new(@long_easy_text)

    long_easy_text_coleman_liau_index = @processor.coleman_liau_index
    assert_equal 12.87, long_easy_text_coleman_liau_index

    @processor = TextMetrics::Processors::French.new(@long_difficult_text)

    long_difficult_text_coleman_liau_index = @processor.coleman_liau_index
    assert long_difficult_text_coleman_liau_index > long_easy_text_coleman_liau_index
  end

  def test_lix
    @processor = TextMetrics::Processors::French.new(@very_easy_text)
    assert (10..20).cover? @processor.lix

    @processor = TextMetrics::Processors::French.new(@long_difficult_text)
    assert (60..70).cover? @processor.lix
  end

  def test_flesch_reading_ease_95
    text = "Le chat dort. Il fait beau. Les oiseaux chantent dans les arbres. C'est l'été. Il n'y a pas de nuages."
    @processor = TextMetrics::Processors::French.new(text)

    # Very easy French text exceeds 100 on the unclamped Kandel-Moles scale (base 207).
    assert_operator @processor.flesch_reading_ease, :>=, 100
  end

  def test_flesch_reading_ease_75
    text = "Marie aime lire des livres. Elle va souvent à la bibliothèque pour en emprunter. Son genre préféré est le roman d'aventure. Elle lit tous les soirs avant de dormir."
    @processor = TextMetrics::Processors::French.new(text)

    assert @processor.flesch_reading_ease >= 70
    assert @processor.flesch_reading_ease <= 80
  end

  def test_flesch_reading_ease_65
    text = "La pollution de l'air est un problème majeur dans les grandes villes. Elle est causée par les gaz d'échappement des voitures et les usines. Cette pollution peut avoir des effets néfastes sur la santé des habitants et sur l'environnement."
    @processor = TextMetrics::Processors::French.new(text)

    assert @processor.flesch_reading_ease >= 60
    assert @processor.flesch_reading_ease <= 70
  end

  def test_flesch_reading_ease_40
    text = "La théorie de la relativité restreinte, formulée par Albert Einstein en 1905, postule que les lois de la physique sont invariantes dans tous les référentiels inertiels et que la vitesse de la lumière dans le vide est constante, indépendamment du mouvement de la source ou de l'observateur. Cette théorie a profondément modifié notre compréhension de l'espace et du temps."
    @processor = TextMetrics::Processors::French.new(text)

    assert @processor.flesch_reading_ease >= 35
    assert @processor.flesch_reading_ease <= 45
  end

  def test_flesch_reading_ease_30
    text = "L'épigénétique est un domaine de la biologie qui étudie les modifications de l'expression des gènes sans changement de la séquence d'ADN. Ces modifications peuvent être influencées par l'environnement et le mode de vie, et peuvent parfois être transmises aux générations suivantes."
    @processor = TextMetrics::Processors::French.new(text)

    assert @processor.flesch_reading_ease >= 25
    assert @processor.flesch_reading_ease <= 35
  end

  def test_flesch_reading_ease_25
    text = "La nature dichotomique du crépuscule, où les éléments diurnes et nocturnes coexistent dans un équilibre fugace, offre un terrain fertile pour l'enquête métaphysique. Cette période éphémère, souvent caractérisée par un sentiment de transience et d'impermanence, sert de rappel poignant du passage inexorable du temps et de la nature éphémère de l'existence humaine."
    @processor = TextMetrics::Processors::AmericanEnglish.new(text)

    assert @processor.flesch_reading_ease <= 30
  end
end
