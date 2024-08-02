<!-- [![Gem Version](https://badge.fury.io/rb/text-metrics.svg)](https://rubygems.org/gems/text-metrics) -->

[![Build](https://github.com/plume-app/text-metrics/workflows/Build/badge.svg)](https://github.com/plume-app/text-metrics/actions)

# Text Metrics

Text Metrics is a Ruby library for text analysis. It is inspired from Textstat library in Python and the Ruby port of [Textstat](https://github.com/kupolak/textstat).

Currently WIP and not ready for production use.

Will focus mostly on French and English text analysis.

## Features

_Basic metrics:_

- word count
- character count
- sentence count
- average syllables per word
- average letters per word
- average sentence length

_Readability tests:_

- Flesch Reading Ease
- Flesch-Kincaid Grade Level
- Gunning Fog Index
- Coleman-Liau Index

## Installation

```ruby
# Gemfile
gem "text-metrics", github: "plume-app/text-metrics", branch: "main"
```

### Supported Ruby versions

- Ruby (MRI) >= 3.0.0

## Usage

```ruby
TextMetrics.new(text: "Hello, world!").word_count
# => 2
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/plume-app/text-metrics](https://github.com/plume-app/text-metrics).

## Credits

This gem was inspired by [Textstat](https://github.com/kupolak/textstat) and [Textstat](https://github.com/textstat/textstat) in Python.
This gem is generated via [`newgem` template](https://github.com/palkan/newgem) by [@palkan](https://github.com/palkan).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
