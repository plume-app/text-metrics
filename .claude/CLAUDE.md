# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`text-metrics` is a Ruby gem for text analysis. It computes basic metrics (word/character/sentence/syllable counts and averages) and readability scores (Flesch Reading Ease, Flesch-Kincaid Grade, SMOG, Coleman-Liau, LIX), plus Levenshtein-based similarity. English (`en_us`) and French (`fr`) are the supported languages. Requires Ruby (MRI) >= 3.1.

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

CI runs `bundle exec rake test` against Ruby 3.1/3.2/3.3/head and `bundle exec rubocop` separately. RuboCop runs from a dedicated gemfile (`BUNDLE_GEMFILE=gemfiles/rubocop.gemfile`).

## Architecture

The public API is a thin facade over per-language processor objects:

- **`TextMetrics.new(text:, language: "en_us")`** (`lib/text_metrics.rb`) returns a `TextMetrics::TextMetrics` instance. That class holds a `PROCESSORS` registry mapping language codes (`"fr"`, `"en_us"`) to processor classes, instantiates the matching processor, and **delegates metric methods to it via `Forwardable` (`def_delegators`)**.

- **`Processors::Base`** (`lib/text_metrics/processors/base.rb`) contains essentially all the logic: the regex tokenizers (`words`, `sentences`, `punctuations` — all memoized), every count/average metric, and the language-agnostic readability scores (`smog_index`, `coleman_liau_index`, `lix`) and `levenshtein_distance_from`. It declares `flesch_reading_ease`/`flesch_kincaid_grade`/`count_syllables_in_word` as the abstract hooks subclasses must provide.

- **`Processors::AmericanEnglish`** and **`Processors::French`** subclass `Base` and override only the language-specific pieces: the Flesch coefficients and `count_syllables_in_word`.

### Key cross-file invariant: the delegator list

When you add a new public metric to `Processors::Base`, you must also add it to the `def_delegators` list in `lib/text_metrics.rb` for it to be callable on the top-level `TextMetrics` instance. The list is currently a **subset** of available metrics — e.g. `lix`, `smog_index`, `coleman_liau_index`, and `punctuations_count` exist on the processor and appear in `#all`, but are *not* delegated, so they're only reachable via `instance.text_metrics_processor.lix` or `instance.all[:lix]`. Keep this in mind both when adding methods and when a method appears "missing" from the facade.

### Syllable counting differs by language

- English uses the `text-hyphen` gem (`Text::Hyphen`) and counts hyphenation points.
- French uses a hand-rolled vowel-pattern heuristic in `count_syllables_in_word`, backed by an exceptions dictionary (`dictionnaries/french_word_syllable_exceptions.yml`, loaded at class-load time into the frozen `SYLLABLE_EXCEPTIONS` constant). The exception lookup is gated by the `with_syllable_exceptions:` constructor flag.

### Generated dictionaries

Files under `lib/text_metrics/dictionnaries/` (the French syllable database and exceptions) are generated from the Lexique-383 corpus (`lexique-383.csv`) by the one-off scripts in `scripts/`. Regenerate via those scripts rather than hand-editing the YAML.

## Conventions

- Linting is **standardrb** (via `require: standard` / `inherit_gem: standard` in `.rubocop.yml`), not vanilla RuboCop style. Follow standard formatting (e.g. no enforced single-vs-double quotes beyond standard's rules) and keep the `# frozen_string_literal: true` magic comment on every file.
- Metric methods guard against empty/zero input by returning `0.0` early, and readability scores `.clamp` their output to a sensible range (e.g. Flesch to `0.0..100.0`). Match this defensive style when adding metrics.

## Releasing

See `RELEASING.md`. Bump `lib/text_metrics/version.rb`, update `CHANGELOG.md`, then `gem release -t && git push --tags` (uses the `gem-release` gem; a tag push triggers the RubyGems publish workflow).
