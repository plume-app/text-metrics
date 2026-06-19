# Change log

## main
- Accept `:en` as an alias for `:en_us` in `TextMetrics.new`.
- Add five metrics to the analyzer and `#to_h`: `automated_readability_index`,
  `type_token_ratio` (lexical diversity), `reading_time` (minutes, with a configurable
  `wpm:`), and the previously-internal `polysyllabic_words_count` and `long_words_count`.

## 1.0.0
- First public release.
- see `UPGRADING.md` for migration details from the pre-release `0.x` API.

## ## 1.0.0.beta2
- Add `gunning_fog_index` to the analyzer metrics and `#to_h` output.

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
- Readability scores are now computed from full-precision ratios (rounding only the final
  result) instead of from the display-rounded averages — this removes errors of several points
  that the intermediate rounding could introduce.
- Readability scores are no longer clamped: a Flesch score can now exceed 100 or go negative,
  as the formulas define. (Previously clamped to 0–100 / 0–18 / 0–20.)
- French Flesch Reading Ease now uses the correct Kandel-Moles base constant `207` (was `206.835`).
- `flesch_kincaid_grade` now uses the standard US-grade formula for every language; the previous
  unsourced French coefficients are gone (Flesch-Kincaid Grade has no validated French adaptation).
- `letters_per_word_average` and the Coleman-Liau index now count alphabetic letters only, not
  digits and punctuation, per the Coleman-Liau definition.
