# frozen_string_literal: true

require "singleton"

class ConfigService
  include Singleton

  def initialize
    @config = load_config
  end

  def get_config(key)
    @config[key]
  end

  private

  def load_config
    YAML.load_file(Rails.root.join("config", "config.yml"))
  end
end

## usage

config_value = ConfigService.instance.get_config("app_name")

puts config_value
