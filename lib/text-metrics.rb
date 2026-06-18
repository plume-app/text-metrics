# frozen_string_literal: true

# Bundler auto-requires the hyphenated gem name (`require "text-metrics"`) by default.
# This shim points it at the real entry point so `gem "text-metrics"` works without an
# explicit `require:` option.
require "text_metrics"
