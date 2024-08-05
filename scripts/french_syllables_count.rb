# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "text_metrics"
require "yaml"

errors = {}
YAML.load_file("lib/text_metrics/dictionnaries/french_word_syllable_database.yml").each do |word, syllables_count|
  @processor = TextMetrics::Processors::French.new(text: word.to_s, with_syllable_exceptions: false)
  errors[word] = syllables_count unless syllables_count.to_i == @processor.syllables_count
end
File.write("lib/text_metrics/dictionnaries/french_word_syllable_exceptions.yml", errors.to_yaml)
