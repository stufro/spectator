require "./abstract_arguments"
require "./arguments"

module Spectator
  # Stores information about a call to a method.
  class MethodCall
    # Name of the method.
    getter method : Symbol

    # Arguments passed to the method.
    getter arguments : AbstractArguments

    # Creates a method call.
    def initialize(@method : Symbol, @arguments : Arguments = Arguments.empty)
    end

    # Creates a method call by splatting its arguments.
    def self.capture(method : Symbol, *args, **kwargs)
      arguments = Arguments.new(args, kwargs)
      new(method, arguments)
    end
  end
end
