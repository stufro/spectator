require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value is in a given range.
  # The `Range#includes?` method is used for this check.
  struct RangeMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Checks whether the matcher is satisifed with the expression given to it.
    private def match?(actual : TestExpression(T)) forall T
      expected.value.includes?(actual.value)
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description
      "is in #{expected.label}"
    end

    # Message displayed when the matcher isn't satisifed.
    #
    # This is only called when `#match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message(actual)
      "#{actual.label} is not in #{expected.label} (#{exclusivity})"
    end

    # Message displayed when the matcher isn't satisifed and is negated.
    # This is essentially what would satisfy the matcher if it wasn't negated.
    #
    # This is only called when `#does_not_match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message_when_negated(actual)
      "#{actual.label} is in #{expected.label} (#{exclusivity})"
    end

    # Additional information about the match failure.
    # The return value is a NamedTuple with Strings for each value.
    private def values(actual)
      {
        lower:  ">= #{range.begin.inspect}",
        upper:  "#{exclusive? ? "<" : "<="} #{range.end.inspect}",
        actual: actual.value.inspect,
      }
    end

    # Additional information about the match failure when negated.
    # The return value is a NamedTuple with Strings for each value.
    private def negated_values(actual)
      {
        lower:  "< #{range.begin.inspect}",
        upper:  "#{exclusive? ? ">=" : ">"} #{range.end.inspect}",
        actual: actual.value.inspect,
      }
    end

    # Returns a new matcher, with the same bounds, but uses an inclusive range.
    def inclusive
      new_range = Range.new(range.begin, range.end, exclusive: false)
      expected = TestValue.new(new_range, label)
      RangeMatcher.new(expected)
    end

    # Returns a new matcher, with the same bounds, but uses an exclusive range.
    def exclusive
      new_range = Range.new(range.begin, range.end, exclusive: true)
      expected = TestValue.new(new_range, label)
      RangeMatcher.new(expected)
    end

    # Gets the expected range.
    private def range
      expected.value
    end

    # Indicates whether the range is inclusive or exclusive.
    private def exclusive?
      range.exclusive?
    end

    # Produces a string "inclusive" or "exclusive" based on the range.
    private def exclusivity
      exclusive? ? "exclusive" : "inclusive"
    end
  end
end
