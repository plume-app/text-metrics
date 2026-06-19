<!-- [![Gem Version](https://badge.fury.io/rb/text-metrics.svg)](https://rubygems.org/gems/text-metrics) -->

[![Build](https://github.com/plume-app/text-metrics/workflows/Build/badge.svg)](https://github.com/plume-app/text-metrics/actions)

# Text Metrics

Text Metrics is a Ruby library for analysing text. It was inspired by the Python Textstat library and the Ruby port of [Textstat](https://github.com/kupolak/textstat).

It gives you the everyday counts you need — words, characters, sentences and syllables — plus readability scores such as Flesch Reading Ease, Flesch-Kincaid Grade Level, SMOG, Gunning Fog, Coleman-Liau Index and LIX. English and French are supported.

It is battle-tested in production on millions of student writings at [Plume](https://plume-app.co).

## Accurate, dictionary-based syllable counting

Readability scores such as Flesch, Flesch-Kincaid and SMOG depend heavily on syllable counts. Many libraries estimate those counts with hyphenation rules, which are fast but often wrong. Text Metrics starts from real pronunciation data instead:

- **English** uses the [CMU Pronouncing Dictionary](https://github.com/cmusphinx/cmudict), which provides pronunciation-derived syllable counts for about 126,000 words. Hyphenation is only used when a word is not in the dictionary. Against CMUdict as ground truth, a hyphenation-only approach gets the syllable count wrong for about **46% of dictionary words**.
- **French** uses counts derived from the [Lexique](http://www.lexique.org/) database, plus a vowel heuristic and an exceptions list for the words the heuristic misses.

That makes syllable-sensitive scores more reliable, especially for longer or less common words.

### Formula notes

- Scores are computed from full-precision ratios and returned **unclamped**. A Flesch Reading Ease score can legitimately be above 100 for very easy text, or below 0 for very difficult text.
- **French Flesch Reading Ease** uses the Kandel-Moles (1958) adaptation: `207 − 1.015 × (words/sentences) − 73.6 × (syllables/words)`. Because the formula starts from 207, very easy French text can score slightly above 100.
- **Flesch-Kincaid Grade** maps to a US school grade. It uses the same formula for every language because there is no validated French adaptation.
- **Gunning Fog** uses words with three or more syllables as complex words, matching the same syllable counts used by SMOG.
- **Coleman-Liau** counts alphabetic letters only (not digits or punctuation), per its definition.
- **Automated Readability Index** counts characters (letters, digits and punctuation, spaces excluded), per its original "strokes" definition — so it uses `characters_count`, unlike Coleman-Liau which uses letters only.
- **Type-token ratio** is distinct-words over total-words and is sensitive to text length: longer texts trend lower because words repeat. Compare it only across texts of similar length.

## Features

_Basic metrics:_

- [x] word count
- [x] character count
- [x] sentence count
- [x] polysyllabic word count (three or more syllables)
- [x] long word count (more than six characters)
- [x] average syllables per word
- [x] average letters per word
- [x] average words per sentence
- [x] average characters per sentence
- [x] type-token ratio (lexical diversity)
- [x] reading time (minutes, configurable words-per-minute)

_Readability tests:_

- [x] Flesch Reading Ease
- [x] Flesch-Kincaid Grade Level
- [x] Smog Index
- [x] Gunning Fog Index
- [x] Coleman-Liau Index
- [x] Lix Index
- [x] Automated Readability Index

## Installation

Text Metrics is not published to RubyGems yet. For now, install it from GitHub:

```ruby
# Gemfile
gem "text-metrics", "~> 1.0.0"
```

### Supported Ruby versions

- Ruby (MRI) >= 3.1.0

## Usage

```ruby
metrics = TextMetrics.new("This gem analyses all kinds of text.")

# Get every metric at once:
metrics.to_h
# {
#   words_count: 7, characters_count: 30, sentences_count: 1, syllables_count: 10,
#   punctuation_count: 1, polysyllabic_words_count: 1, long_words_count: 1,
#   syllables_per_word_average: 1.4, letters_per_word_average: 4.14,
#   words_per_sentence_average: 7.0, characters_per_sentence_average: 30.0,
#   words_per_punctuation_average: 7.0, punctuation_per_sentence_average: 1.0,
#   type_token_ratio: 1.0, flesch_reading_ease: 78.87, flesch_kincaid_grade: 4.0,
#   lix: 21.29, smog_index: 0.0, gunning_fog_index: 8.5, coleman_liau_index: 4.33,
#   automated_readability_index: 2.3, reading_time: 0.04
# }

# Or ask for a single metric:
metrics.words_count                     # => 7
metrics.characters_count                # => 30
metrics.flesch_reading_ease             # => 78.87
metrics.flesch_kincaid_grade            # => 4.0
metrics.gunning_fog_index                # => 8.5

# Reading time is in minutes; pass a custom reading pace if you like:
metrics.reading_time                    # => 0.04   (at the default 200 wpm)
metrics.reading_time(wpm: 130)          # => 0.05
```

### Languages

American English (`:en_us`) is the default. To analyse French text, pass `language: :fr`:

```ruby
TextMetrics.new("Bonjour le monde.", language: :fr)
```

Unsupported languages raise `TextMetrics::Error`.

### Configuration

Global defaults can be set via `TextMetrics.configure`. Call this once at boot time — in a Rails initializer, for example:

```ruby
TextMetrics.configure do |config|
  # Words per minute used by #reading_time (default: 200).
  config.wpm = 250
end
```

In a **Rails app**, generate the initializer with:

```sh
rails generate text_metrics:install
```

This creates `config/initializers/text_metrics.rb` with the options commented out at their defaults.

Per-call overrides are still supported and always take precedence over the global config:

```ruby
metrics.reading_time(wpm: 130)
```

### Comparing two texts

Levenshtein distance compares two strings, so it is exposed on the `TextMetrics` module:

```ruby
TextMetrics.distance("kitten", "sitting")   # => 3      raw edit distance
TextMetrics.similarity("kitten", "sitting") # => 57.14  0–100 score (100.0 == identical)
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/plume-app/text-metrics).

## Credits

This gem was inspired by [Textstat](https://github.com/textstat/textstat) in Python and the Ruby [Textstat](https://github.com/kupolak/textstat) port.
It was generated from the [`newgem` template](https://github.com/palkan/newgem) by [@palkan](https://github.com/palkan).

English syllable counts come from the [CMU Pronouncing Dictionary](https://github.com/cmusphinx/cmudict) (unrestricted use), with [text-hyphen](https://github.com/halostatue/text-hyphen) as a fallback. French syllable counts are derived from [Lexique](http://www.lexique.org/).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
