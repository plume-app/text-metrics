# frozen_string_literal: true

module TextMetrics
  class Railtie < Rails::Railtie
    generators do
      require "generators/text_metrics/install_generator"
    end
  end
end
