<!-- [![Gem Version](https://badge.fury.io/rb/text-metrics.svg)](https://rubygems.org/gems/text-metrics) -->

[![Build](https://github.com/plume-app/text-metrics/workflows/Build/badge.svg)](https://github.com/plume-app/text-metrics/actions)

# Text Metrics

Text Metrics is a Ruby library for analysing text. It was inspired by the Python Textstat library and the Ruby port of [Textstat](https://github.com/kupolak/textstat).

It gives you the everyday counts you need — words, characters, sentences and syllables — plus readability scores such as Flesch Reading Ease, Flesch-Kincaid Grade Level, SMOG, Coleman-Liau Index and LIX. English and French are supported.

## Accurate, dictionary-based syllable counting

Readability scores such as Flesch, Flesch-Kincaid and SMOG depend heavily on syllable counts. Many libraries estimate those counts with hyphenation rules, which are fast but often wrong. Text Metrics starts from real pronunciation data instead:

- **English** uses the [CMU Pronouncing Dictionary](https://github.com/cmusphinx/cmudict), which provides pronunciation-derived syllable counts for about 126,000 words. Hyphenation is only used when a word is not in the dictionary. Against CMUdict as ground truth, a hyphenation-only approach gets the syllable count wrong for about **46% of dictionary words**.
- **French** uses counts derived from the [Lexique](http://www.lexique.org/) database, plus a vowel heuristic and an exceptions list for the words the heuristic misses.

That makes syllable-sensitive scores more reliable, especially for longer or less common words.

### Formula notes

- Scores are computed from full-precision ratios and returned **unclamped**. A Flesch Reading Ease score can legitimately be above 100 for very easy text, or below 0 for very difficult text.
- **French Flesch Reading Ease** uses the Kandel-Moles (1958) adaptation: `207 − 1.015 × (words/sentences) − 73.6 × (syllables/words)`. Because the formula starts from 207, very easy French text can score slightly above 100.
- **Flesch-Kincaid Grade** maps to a US school grade. It uses the same formula for every language because there is no validated French adaptation.
- **Coleman-Liau** counts alphabetic letters only (not digits or punctuation), per its definition.

## Features

_Basic metrics:_

- [x] word count
- [x] character count
- [x] sentence count
- [x] average syllables per word
- [x] average letters per word
- [x] average words per sentence
- [x] average characters per sentence

_Readability tests:_

- [x] Flesch Reading Ease
- [x] Flesch-Kincaid Grade Level
- [x] Smog Index
- [x] Coleman-Liau Index
- [x] Lix Index
- [ ] Gunning Fog Index

## Installation

Text Metrics is not published to RubyGems yet. For now, install it from GitHub:

```ruby
# Gemfile
gem "text-metrics", github: "plume-app/text-metrics", branch: "main"
```

### Supported Ruby versions

- Ruby (MRI) >= 3.1.0

## Usage

```ruby
metrics = TextMetrics.new("This gem analyses all kinds of text.")

# Get every metric at once:
metrics.to_h
# {
#   words_count: 7, characters_count: 30, sentences_count: 1, syllables_count: 11,
#   punctuation_count: 1, syllables_per_word_average: 1.6, letters_per_word_average: 4.29,
#   words_per_sentence_average: 7.0, characters_per_sentence_average: 30.0,
#   words_per_punctuation_average: 7.0, punctuation_per_sentence_average: 1.0,
#   flesch_reading_ease: 64.37, flesch_kincaid_grade: 6.0, lix: 21.29,
#   smog_index: 0.0, coleman_liau_index: 5.2
# }

# Or ask for a single metric:
metrics.words_count                     # => 7
metrics.characters_count                # => 30
metrics.flesch_reading_ease             # => 64.37
metrics.flesch_kincaid_grade            # => 6.0
```

### Languages

American English (`:en_us`) is the default. To analyse French text, pass `language: :fr`:

```ruby
TextMetrics.new("Bonjour le monde.", language: :fr)
```

Unsupported languages raise `TextMetrics::Error`.

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
