# frozen_string_literal: true

require "text/hyphen"

module TextMetrics
  module Processors
    class Base
      attr_reader :text, :with_syllable_exceptions

      def initialize(text:, with_syllable_exceptions: true)
        @text = text&.downcase&.squeeze(" ") || ""
        @with_syllable_exceptions = with_syllable_exceptions
      end

      def all
        @all ||= {
          words_count: words_count,
          characters_count: characters_count,
          sentences_count: sentences_count,
          syllables_count: syllables_count,
          punctuations_count: punctuations_count,
          syllables_per_word_average: syllables_per_word_average,
          letters_per_word_average: letters_per_word_average,
          words_per_sentence_average: words_per_sentence_average,
          words_per_punctuations_average: words_per_punctuations_average,
          characters_per_sentence_average: characters_per_sentence_average,
          punctuations_per_sentence_average: punctuations_per_sentence_average,
          flesch_reading_ease: flesch_reading_ease,
          flesch_kincaid_grade: flesch_kincaid_grade,
          lix: lix,
          smog_index: smog_index,
          coleman_liau_index: coleman_liau_index
        }
      end

      # _count methods
      def characters_count(ignore_spaces: true)
        ignore_spaces ? text.delete(" ").length : text.length
      end

      def words_count
        words.size
      end

      def sentences_count
        return 0 if words_count.zero?

        [1, sentences.size].max
      end

      def syllables_count
        words.sum { |word| count_syllables_in_word(word) }
      end

      def poly_syllabes_count
        words.count { |word| count_syllables_in_word(word) >= 3 }
      end

      def punctuations_count
        punctuations.size
      end

      # _average methods

      def syllables_per_word_average
        return 0.0 if words_count.zero? || syllables_count.zero?

        (syllables_count.to_f / words_count).round(1)
      end

      def letters_per_word_average
        return 0.0 if words_count.zero? || characters_count.zero?

        (characters_count.to_f / words_count).round(2)
      end

      def words_per_sentence_average
        return 0.0 if words_count.zero? || sentences_count.zero?

        (words_count.to_f / sentences_count).round(2)
      end

      def characters_per_sentence_average
        return 0.0 if characters_count.zero? || sentences_count.zero?

        (characters_count.to_f / sentences_count).round(2)
      end

      def punctuations_per_sentence_average
        return 0.0 if punctuations_count.zero? || sentences_count.zero?

        (punctuations_count.to_f / sentences_count).round(2)
      end

      def words_per_punctuations_average
        return 0.0 if words_count.zero? || punctuations_count.zero?

        (words_count.to_f / punctuations_count).round(2)
      end

      # readability scores
      def flesch_reading_ease
        raise NotImplementedError
      end

      def flesch_kincaid_grade
        raise NotImplementedError
      end

      def smog_index
        if sentences_count >= 3
          begin
            smog = 1.043 * Math.sqrt(30.0 * poly_syllabes_count / sentences_count) + 3.1291
            smog.round(1)
          rescue ZeroDivisionError
            0.0
          end
        else
          0.0
        end
      end

      def coleman_liau_index
        return 0.0 if words_per_sentence_average.zero? || letters_per_word_average.zero?

        letters = (letters_per_word_average * 100).round(2)
        sentences = (1.to_f / words_per_sentence_average * 100).round(2)
        coleman = 0.0588 * letters - 0.296 * sentences - 15.8
        coleman.round(2).clamp(0.0, 20.0)
      end

      def lix
        return 0.0 if words_count.zero?

        long_words = words.count { |word| word.length > 6 }

        per_long_words = 100.0 * long_words / words_count
        lix = words_per_sentence_average + per_long_words

        lix.round(2).clamp(0.0, 100.0)
      end

      # tokenizers
      #
      def punctuations
        @punctuations ||= text.scan(/[.,!?;:]/)
      end

      def words
        @words ||= begin
          normalized_text = text.downcase.strip

          # Split the sentence into words, including hyphenated words, and excluding numbers
          normalized_text.scan(/\b[A-Za-zÀ-ÖØ-öø-ÿ'-]+\b/)
        end
      end

      def sentences
        @sentences ||= text.scan(/(?<!\w\.\w.)(?<![A-Z][a-z]\.)(?<=\.|\?|!)(?=\s|$)/)
      end
    end
  end
end
