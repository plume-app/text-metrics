# frozen_string_literal: true

require "rails/generators"

module TextMetrics
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Creates a TextMetrics initializer in config/initializers"

      def create_initializer
        create_file "config/initializers/text_metrics.rb", <<~RUBY
          # frozen_string_literal: true

          TextMetrics.configure do |config|
            # Words per minute used to compute reading_time (default: 200).
            # config.wpm = 200
          end
        RUBY
      end
    end
  end
end
