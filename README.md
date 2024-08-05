<!-- [![Gem Version](https://badge.fury.io/rb/text-metrics.svg)](https://rubygems.org/gems/text-metrics) -->

[![Build](https://github.com/plume-app/text-metrics/workflows/Build/badge.svg)](https://github.com/plume-app/text-metrics/actions)

# Text Metrics

Text Metrics is a Ruby library for text analysis. It is inspired from Textstat library in Python and the Ruby port of [Textstat](https://github.com/kupolak/textstat).

In addition to basic metrics it also provides readability tests like Flesch Reading Ease, Flesch-Kincaid Grade Level, Gunning Fog Index, Coleman-Liau Index.

At this point the main language supported are English and French.

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
- [ ] Gunning Fog Index
- [ ] Coleman-Liau Index

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
@text_analyser = TextMetrics.new(text: "This gem analyses all kind of texts.")
# get all metrics at once:

@text_analyser.all
# { words_count: 7, characters_count: 30, sentences_count: 1, syllables_count: 9, syllables_per_word_average: 1.3, letters_per_word_average: 4.29, words_per_sentence_average: 7.0, characters_per_sentence_average: 30.0, flesch_reading_ease: 89.75, flesch_kincaid_grade: 2.5 }

# or get each metric separately:
@text_analyser.words_count # => 7
@text_analyser.characters_count # => 30
@text_analyser.sentences_count # => 1
@text_analyser.syllables_count # => 9
@text_analyser.syllables_per_word_average # => 1.3
@text_analyser.letters_per_word_average # => 4.29
@text_analyser.words_per_sentence_average # => 7.0
@text_analyser.characters_per_sentence_average # => 30.0
@text_analyser.flesch_reading_ease # => 89.75
@text_analyser.flesch_kincaid_grade # => 2.5
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/plume-app/text-metrics](https://github.com/plume-app/text-metrics).

## Credits

This gem was inspired by [Textstat](https://github.com/kupolak/textstat) and [Textstat](https://github.com/textstat/textstat) in Python.
This gem is generated via [`newgem` template](https://github.com/palkan/newgem) by [@palkan](https://github.com/palkan).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
