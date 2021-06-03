module Spectator
  # Filter that matches examples on a given line.
  class LineExampleFilter < ExampleFilter
    # Creates the example filter.
    def initialize(@line : Int32)
    end

    # Checks whether the example satisfies the filter.
    def includes?(example) : Bool
      return false unless location = example.location?

      start_line = location.line
      end_line = location.end_line
      (start_line..end_line).covers?(@line)
    end
  end
end
