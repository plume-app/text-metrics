# frozen_string_literal: true

module TextMetrics
  class Configuration
    attr_accessor :wpm

    def initialize
      @wpm = 200
    end
  end
end
