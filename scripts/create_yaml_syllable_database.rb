# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "text_metrics"
require "yaml"
require "csv"

csv = CSV.read("lib/text_metrics/dictionnaries/lexique-383.csv", headers: true)
WORDS_TO_IGNORE = ["etc.", "i.e.", "p.", "p.m."]

hash = {}
csv.each do |row|
  next if row["1_ortho"].split.size != 1
  next if WORDS_TO_IGNORE.include?(row["1_ortho"])

  syllables_count = row["28_orthosyll"]&.split("-")&.size || row["24_nbsyll"].to_i
  hash[row["1_ortho"]] = syllables_count
end

File.write("lib/text_metrics/dictionnaries/french_word_syllable_database.yml", hash.to_yaml)
