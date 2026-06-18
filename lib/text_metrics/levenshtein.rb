# frozen_string_literal: true

module TextMetrics
  # Levenshtein edit distance between two strings, plus a normalized similarity score.
  # Comparison is a property of two texts, so it lives here rather than on a single-text analyzer.
  module Levenshtein
    module_function

    # Raw edit distance: the number of single-character insertions, deletions or
    # substitutions needed to turn +first+ into +second+. Case-sensitive.
    def distance(first, second)
      first = first.to_s
      second = second.to_s
      m = first.length
      n = second.length

      return n if m.zero?
      return m if n.zero?

      matrix = Array.new(m + 1) { Array.new(n + 1, 0) }
      (0..m).each { |i| matrix[i][0] = i }
      (0..n).each { |j| matrix[0][j] = j }

      (1..m).each do |i|
        (1..n).each do |j|
          cost = (first[i - 1] == second[j - 1]) ? 0 : 1
          matrix[i][j] = [
            matrix[i - 1][j] + 1,        # deletion
            matrix[i][j - 1] + 1,        # insertion
            matrix[i - 1][j - 1] + cost  # substitution
          ].min
        end
      end

      matrix[m][n]
    end

    # Similarity as a 0–100 score: 100.0 means identical, 0.0 means nothing in common.
    def similarity(first, second)
      max_length = [first.to_s.length, second.to_s.length].max
      return 100.0 if max_length.zero?

      ((max_length - distance(first, second)).to_f / max_length * 100).round(2)
    end
  end
end
