# frozen_string_literal: true

## Old way to define the singleton class
class SingletonClass
  include SingletonModule

  private_class_method :new

  def some_method
    puts "Hello, I'm a method of SingletonClass"
  end
end
