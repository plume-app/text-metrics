<!-- [![Gem Version](https://badge.fury.io/rb/text-metrics.svg)](https://rubygems.org/gems/text-metrics) -->

[![Build](https://github.com/plume-app/text-metrics/workflows/Build/badge.svg)](https://github.com/plume-app/text-metrics/actions)

# Text Metrics

Text Metrics is a Ruby library for text analysis. It is inspired from Textstat library in Python and the Ruby port of [Textstat](https://github.com/kupolak/textstat).

In addition to basic metrics it also provides readability tests like Flesch Reading Ease, Flesch-Kincaid Grade Level, SMOG, Coleman-Liau Index and LIX. The main languages supported are English and French.

## Accurate, dictionary-based syllable counting

Readability scores (Flesch, Flesch-Kincaid, SMOG) are only as trustworthy as the syllable counts they are built on — and the hyphenation heuristics most libraries rely on get a lot of words wrong. Text Metrics counts syllables from real pronunciation dictionaries instead:

- **English** uses the [CMU Pronouncing Dictionary](https://github.com/cmusphinx/cmudict): pronunciation-derived syllable counts for ~126,000 words, falling back to hyphenation only for out-of-vocabulary words. Benchmarked against CMUdict as ground truth, the common hyphenation-only approach returns the **wrong** syllable count for **~46% of dictionary words** — Text Metrics uses the reference count directly.
- **French** uses counts derived from the [Lexique](http://www.lexique.org/) database, with a vowel heuristic patched by an exceptions list for the words it gets wrong.

This makes syllable-dependent metrics meaningfully more accurate than hyphenation-only implementations, especially on longer and less common words.

### Formula notes

- Scores are computed from full-precision ratios and returned **unclamped** — a Flesch Reading Ease score can legitimately exceed 100 (very easy) or go below 0 (very difficult).
- **French Flesch Reading Ease** uses the Kandel-Moles (1958) adaptation: `207 − 1.015 × (words/sentences) − 73.6 × (syllables/words)`. Because its base is 207, very easy French text can score slightly above 100.
- **Flesch-Kincaid Grade** maps to a US school grade and uses the same formula for all languages (there is no validated French adaptation).
- **Coleman-Liau** counts alphabetic letters only (not digits or punctuation), per its definition.

## Features

_Basic metrics:_

- [x] words count
- [x] characters count
- [x] sentences count
- [x] syllables per word average
- [x] letters per word average
- [x] sentence length average
- [x] sentence length (characters) average

_Readability tests:_

- [x] Flesch Reading Ease
- [x] Flesch-Kincaid Grade Level
- [x] Smog Index
- [x] Coleman-Liau Index
- [x] Lix Index
- [ ] Gunning Fog Index

## Installation

No official release yet, but you can install it from GitHub:

```ruby
# Gemfile
gem "text-metrics", github: "plume-app/text-metrics", branch: "main"
```

### Supported Ruby versions

- Ruby (MRI) >= 3.1.0

## Usage

```ruby
metrics = TextMetrics.new("This gem analyses all kinds of text.")

# Get every metric at once as a Hash:
metrics.to_h
# {
#   words_count: 7, characters_count: 30, sentences_count: 1, syllables_count: 11,
#   punctuation_count: 1, syllables_per_word_average: 1.6, letters_per_word_average: 4.29,
#   words_per_sentence_average: 7.0, characters_per_sentence_average: 30.0,
#   words_per_punctuation_average: 7.0, punctuation_per_sentence_average: 1.0,
#   flesch_reading_ease: 64.37, flesch_kincaid_grade: 6.0, lix: 21.29,
#   smog_index: 0.0, coleman_liau_index: 5.2
# }

# Or read each metric on its own:
metrics.words_count                     # => 7
metrics.characters_count                # => 30
metrics.flesch_reading_ease             # => 64.37
metrics.flesch_kincaid_grade            # => 6.0
```

### Languages

The default language is American English (`:en_us`). Pass `language:` to analyse French:

```ruby
TextMetrics.new("Bonjour le monde.", language: :fr)
```

An unknown language raises `TextMetrics::Error`.

### Comparing two texts

Levenshtein comparison is between two texts, so it lives on the module itself:

```ruby
TextMetrics.distance("kitten", "sitting")   # => 3      raw edit distance
TextMetrics.similarity("kitten", "sitting") # => 57.14  0–100 score (100.0 == identical)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/plume-app/text-metrics](https://github.com/plume-app/text-metrics).

## Credits

This gem was inspired by [Textstat](https://github.com/kupolak/textstat) and [Textstat](https://github.com/textstat/textstat) in Python.
This gem is generated via [`newgem` template](https://github.com/palkan/newgem) by [@palkan](https://github.com/palkan).

English syllable counts come from the [CMU Pronouncing Dictionary](https://github.com/cmusphinx/cmudict) (unrestricted use), with [text-hyphen](https://github.com/halostatue/text-hyphen) as a fallback. French syllable counts are derived from [Lexique](http://www.lexique.org/).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
