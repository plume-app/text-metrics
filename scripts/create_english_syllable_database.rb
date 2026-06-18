# frozen_string_literal: true

# Builds the English syllable database from the CMU Pronouncing Dictionary.
#
# In CMUdict every vowel phoneme carries a stress marker (0, 1 or 2), so the
# syllable count is simply the number of phonemes ending in a digit. Only the
# first (primary) pronunciation of each word is kept.
#
# The database is written as a compact "word count" text file (one entry per line,
# sorted). It is parsed manually at runtime, which loads ~125k entries an order of
# magnitude faster than YAML and stays diffable in git.
#
# Source: https://github.com/cmusphinx/cmudict (cmudict.dict)

SOURCE = "data/cmudict.dict"
TARGET = "lib/text_metrics/dictionaries/english_word_syllable_database.txt"

database = {}

File.foreach(SOURCE) do |line|
  line = line.split("#", 2).first.to_s.strip # drop inline comments
  next if line.empty?

  headword, *phones = line.split(/\s+/)
  next if phones.empty?

  word = headword.sub(/\(\d+\)\z/, "").downcase # strip the (2) variant marker
  next unless word.match?(/[a-z]/) # skip punctuation-name entries
  next if database.key?(word) # keep the primary pronunciation only

  database[word] = phones.count { |phone| phone.end_with?("0", "1", "2") }
end

File.open(TARGET, "w") do |file|
  database.sort.each { |word, count| file.puts("#{word} #{count}") }
end
puts "Wrote #{database.size} words to #{TARGET}"
