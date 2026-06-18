# frozen_string_literal: true

require_relative "lib/text_metrics/version"

Gem::Specification.new do |s|
  s.name = "text-metrics"
  s.version = TextMetrics::VERSION
  s.authors = ["Adrien POLY"]
  s.email = ["adrienpoly@gmail.com"]
  s.homepage = "https://github.com/plume-app/text-metrics"
  s.summary = "Readability scores and text statistics for English and French"
  s.description = "Text Metrics computes readability scores (Flesch Reading Ease, " \
    "Flesch-Kincaid Grade, SMOG, Coleman-Liau, LIX) along with word, sentence, syllable and " \
    "character statistics, plus Levenshtein distance and similarity. English and French are supported."

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/plume-app/text-metrics/issues",
    "changelog_uri" => "https://github.com/plume-app/text-metrics/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://github.com/plume-app/text-metrics",
    "homepage_uri" => "https://github.com/plume-app/text-metrics",
    "source_code_uri" => "https://github.com/plume-app/text-metrics"
  }

  s.license = "MIT"

  s.files = Dir.glob("lib/**/*") + Dir.glob("bin/**/*") + %w[README.md LICENSE.txt CHANGELOG.md UPGRADING.md]
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 3.1"

  s.add_runtime_dependency "text-hyphen", ">= 1.5.0"
  s.add_development_dependency "bundler", ">= 1.15"
  s.add_development_dependency "rake", ">= 13.0"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-minitest"
  s.add_development_dependency "byebug"
end
