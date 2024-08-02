# frozen_string_literal: true

module TextMetrics
  module Processors
    class Base
      attr_reader :text

      def initialize(text:)
        @text = text
      end

      def word_count
        @word_count ||= words.size
      end

      private

      def words
        @words ||= text.split
      end
    end
  end
end
