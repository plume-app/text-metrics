# Change log

## master

## 1.0.0.beta1

First public (beta) release. The API was reworked for stability before tagging 1.0 — see
[`UPGRADING.md`](UPGRADING.md) for migration details. **Breaking changes:**

- `TextMetrics.new` now takes the text as a positional argument and returns the
  language-specific analyzer directly: `TextMetrics.new("text", language: :en_us)`.
  The `TextMetrics::TextMetrics` wrapper and its `#text_metrics_processor` accessor are gone.
- `language` is now a symbol (`:en_us`, `:fr`); strings are still accepted. An unknown
  language raises `TextMetrics::Error` instead of a `NoMethodError`.
- `#all` was renamed to `#to_h`, and it is now the single source of truth for the metric
  set — every individual reader and `#to_h` are derived from the same list, so they can't drift.
- Levenshtein moved off the analyzer to the module: `TextMetrics.distance(a, b)` (raw integer)
  and `TextMetrics.similarity(a, b)` (0–100 score). This replaces
  `levenshtein_distance_from(other, normalize:)`, whose return value changed meaning with the flag.
- Punctuation metrics renamed to the singular: `punctuation_count`,
  `words_per_punctuation_average`, `punctuation_per_sentence_average`.
- `poly_syllabes_count` and the tokenizers are now private implementation details.
- Analyzed text is whitespace-normalized once and exposed via `#text`.
- English syllable counting now uses the CMU Pronouncing Dictionary as the source of truth
  (falling back to `text-hyphen` only for out-of-vocabulary words), which is more accurate than
  the previous hyphenation-only approach. English syllable counts and the readability scores
  derived from them may shift slightly versus `0.x`.
