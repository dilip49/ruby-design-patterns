# frozen_string_literal: true

module SingletonModule
  def self.included(base)
    def base.instance
      @instance ||= new
    end
  end
end
