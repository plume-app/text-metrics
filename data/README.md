# Dictionary sources (development only)

This folder holds the raw corpora and heavy intermediate files used to **generate** the
syllable dictionaries. It is intentionally **outside `lib/`** so it is *not* packaged into the
released gem (the gemspec only ships `lib/**/*`). Only the small processed files the gem loads
at runtime live under `lib/text_metrics/dictionaries/`.

| File                                | Role         | Used by                                              |
| ----------------------------------- | ------------ | ---------------------------------------------------- |
| `cmudict.dict`                      | raw source   | `scripts/create_english_syllable_database.rb`        |
| `lexique-383.csv`                   | raw source   | `scripts/create_yaml_syllable_database.rb`           |
| `french_word_syllable_database.yml` | intermediate | `scripts/french_syllables_count.rb`, the corpus test |
| `en_us.txt`, `fr.txt`               | unused word lists kept for reference | —                            |

## Regenerating

Run from the repository root:

```sh
ruby scripts/create_english_syllable_database.rb  # -> lib/.../english_word_syllable_database.txt
ruby scripts/create_yaml_syllable_database.rb     # -> data/french_word_syllable_database.yml
ruby scripts/french_syllables_count.rb            # -> lib/.../french_word_syllable_exceptions.yml
```

## Provenance

- `cmudict.dict` — [CMU Pronouncing Dictionary](https://github.com/cmusphinx/cmudict). Use is completely unrestricted.
- `lexique-383.csv` — [Lexique](http://www.lexique.org/) (French lexical database).
