# Upgrading

## To 1.0 (from the pre-release `0.x` internal API)

1.0 is the first public release. The internal `0.x` API was reworked once, deliberately, so
the public surface can stay stable from here on. Everything below is a one-time migration.

### Building an analyzer

`text` is now positional, and `TextMetrics.new` returns the analyzer itself — there is no
longer a wrapper object with a `text_metrics_processor` accessor.

```ruby
# Before
analyser = TextMetrics.new(text: "Some text", language: "fr")
analyser.text_metrics_processor.words_count

# After
metrics = TextMetrics.new("Some text", language: :fr)
metrics.words_count
```

### Languages are symbols, and unknown ones raise

```ruby
# Before — unknown language blew up with NoMethodError on nil
TextMetrics.new(text: "x", language: "es")

# After — symbols (strings still accepted), unknown languages raise TextMetrics::Error
TextMetrics.new("x", language: :es) # => raises TextMetrics::Error
```

### `#all` is now `#to_h`

```ruby
# Before
metrics.all

# After
metrics.to_h
```

`#to_h` and the individual metric readers are now generated from a single list
(`TextMetrics::Processors::Base::METRICS`), so they can never report different sets again.

### Levenshtein moved to the module

The single method with a `normalize:` flag (which returned a raw distance or a 0–100 score
depending on the flag) is replaced by two intention-revealing module methods:

```ruby
# Before
metrics.levenshtein_distance_from("other", normalize: false) # raw distance
metrics.levenshtein_distance_from("other")                   # 0–100 score

# After
TextMetrics.distance("text", "other")   # => Integer, raw edit distance
TextMetrics.similarity("text", "other") # => Float, 0–100 score (100.0 == identical)
```

### Renamed metrics

The punctuation metrics dropped the plural; some helpers are now private:

| Before                             | After                            |
| ---------------------------------- | -------------------------------- |
| `punctuations_count`               | `punctuation_count`              |
| `words_per_punctuations_average`   | `words_per_punctuation_average`  |
| `punctuations_per_sentence_average`| `punctuation_per_sentence_average` |
| `poly_syllabes_count` (public)     | private implementation detail    |

The word/sentence/punctuation tokenizers are now private as well — use the count and average
metrics or `#to_h`.
