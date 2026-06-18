# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`text-metrics` is a Ruby gem for text analysis. It computes basic metrics (word/character/sentence/syllable counts and averages) and readability scores (Flesch Reading Ease, Flesch-Kincaid Grade, SMOG, Coleman-Liau, LIX), plus Levenshtein distance/similarity. English (`:en_us`) and French (`:fr`) are supported. Requires Ruby (MRI) >= 3.1.

## Commands

```sh
bundle exec rake test                                      # run the full test suite (Minitest)
bundle exec rake test TEST=test/text_metrics/processors/french_test.rb   # run a single test file
bundle exec rake test TESTOPTS="--name=/flesch/"           # run tests matching a name pattern
bundle exec rubocop                                        # lint Ruby (uses standardrb config)
bundle exec rake rubocop:md                                # lint Markdown (.rubocop-md.yml)
bundle exec rake                                           # default: rubocop, rubocop:md, then test
bundle exec guard                                          # watch files and auto-run tests (Guardfile)
```

CI runs `bundle exec rake test` against Ruby 3.1/3.2/3.3/head and `bundle exec rubocop` separately, from a dedicated gemfile (`BUNDLE_GEMFILE=gemfiles/rubocop.gemfile`). That gemfile (and `rubocop-md`) may not be installed locally — `bundle exec rubocop` via the default Gemfile works for the Ruby lint.

## Architecture

The public API is the module plus per-language analyzer objects:

- **`TextMetrics.new(text, language: :en_us)`** (`lib/text_metrics.rb`) is a factory: it looks the language up in the `PROCESSORS` registry and returns the matching analyzer instance directly (e.g. a `Processors::French`). There is intentionally **no wrapper/facade object** — the processor *is* the public analyzer. Unknown languages raise `TextMetrics::Error`; language accepts a symbol or string.

- **`Processors::Base`** (`lib/text_metrics/processors/base.rb`) holds essentially all the logic: regex tokenizers (`words`, `sentences`, `punctuation_marks` — private, memoized), every count/average metric, and the language-agnostic readability scores (`smog_index`, `coleman_liau_index`, `lix`). `flesch_reading_ease` / `flesch_kincaid_grade` / `count_syllables_in_word` are the abstract hooks subclasses provide.

- **`Processors::AmericanEnglish`** and **`Processors::French`** subclass `Base` and override only the language-specific pieces: the Flesch coefficients and `count_syllables_in_word`.

- **`TextMetrics::Levenshtein`** (`lib/text_metrics/levenshtein.rb`) is a stateless module exposing `distance` (raw Integer) and `similarity` (0–100 Float). Comparison is between two texts, so it lives here, not on a single-text analyzer. `TextMetrics.distance` / `TextMetrics.similarity` delegate to it.

### `METRICS` is the single source of truth

`Processors::Base::METRICS` is the canonical list of public metrics. `#to_h` is generated from it via `public_send`, and the individual reader methods are the same names. **When adding or removing a metric, edit `METRICS` and define the matching reader** — never maintain a separate list. This is deliberate: an earlier design hand-maintained a `Forwardable` delegator list that drifted out of sync with the metrics hash. Don't reintroduce that pattern.

### Syllable counting differs by language

- **English** is dictionary-primary: `AmericanEnglish#count_syllables_in_word` looks the word up in the CMU Pronouncing Dictionary (`dictionaries/english_word_syllable_database.txt`) and only falls back to the `text-hyphen` gem for out-of-vocabulary words. The database is parsed lazily once into a shared class-level hash (`AmericanEnglish.syllable_database`) — lazy so requiring the gem or using only French/Levenshtein doesn't pay the ~90ms load. Dictionary-primary (not exceptions-over-heuristic like French) because `text-hyphen` disagrees with CMUdict on ~46% of words, so an exceptions list would be larger than the dictionary itself.
- **French** uses a vowel-pattern heuristic in `count_syllables_in_word`, backed by an exceptions dictionary (`dictionaries/french_word_syllable_exceptions.yml`, loaded once into the frozen `SYLLABLE_EXCEPTIONS` constant). The `with_syllable_exceptions:` flag on `French#initialize` is an **internal** toggle used only by the dictionary-generation scripts to run the bare heuristic; it is not exposed through `TextMetrics.new`.

### Generated dictionaries — `data/` (dev) vs `lib/` (shipped)

Raw corpora and heavy intermediates live in **`data/`** (outside `lib/`, so the gemspec's `lib/**/*` glob keeps them **out of the packaged gem**). Only the two files loaded at runtime are committed under `lib/text_metrics/dictionaries/`: `english_word_syllable_database.txt` and `french_word_syllable_exceptions.yml`. Regenerate via the `scripts/` rather than hand-editing; see `data/README.md`.

- **French** (from Lexique-383, `data/lexique-383.csv`): `create_yaml_syllable_database.rb` builds `data/french_word_syllable_database.yml` (intermediate, used by the corpus test); `french_syllables_count.rb` builds the runtime exceptions file in `lib/`.
- **English** (from CMUdict, `data/cmudict.dict`): `create_english_syllable_database.rb` writes the runtime `english_word_syllable_database.txt` in `lib/`, a compact `word count` file (syllables = number of stress-marked vowel phonemes; primary pronunciation only). Compact text, not YAML, because it parses ~10× faster for 126k entries and stays diffable.

## Conventions

- Linting is **standardrb** (via `require: standard` / `inherit_gem: standard` in `.rubocop.yml`), not vanilla RuboCop style. Keep the `# frozen_string_literal: true` magic comment on every file.
- Metric methods guard against empty/zero input by returning `0.0` early, and readability scores `.clamp` their output to a sensible range (e.g. Flesch to `0.0..100.0`). Match this defensive style when adding metrics.
- The public surface is intentionally narrow: tokenizers and syllable helpers are private. Adding a public method later is non-breaking; removing one isn't — start private.

## Releasing

See `RELEASING.md`. Bump `lib/text_metrics/version.rb`, update `CHANGELOG.md` (and `UPGRADING.md` for breaking changes), then `gem release -t && git push --tags` (uses `gem-release`; a tag push triggers the RubyGems publish workflow).
