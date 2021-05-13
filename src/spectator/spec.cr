require "./config"
require "./example_group"
require "./spec/*"

module Spectator
  # Contains examples to be tested and configuration for running them.
  class Spec
    # Creates the spec.
    # The *root* is the top-most example group.
    # All examples in this group and groups nested under are candidates for execution.
    # The *config* provides settings controlling how tests will be executed.
    def initialize(@root : ExampleGroup, @config : Config)
    end

    # Runs all selected examples and returns the results.
    def run
      Runner.new(examples, @config.run_flags).run
    end

    # Selects and shuffles the examples that should run.
    private def examples
      iterator = @config.iterator(@root)
      iterator.to_a.tap do |examples|
        @config.shuffle!(examples)
      end
    end
  end
end
