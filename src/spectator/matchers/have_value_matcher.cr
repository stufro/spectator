require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a `Hash` (or similar type) has a given value.
  # The set is checked with the `has_value?` method.
  struct HaveValueMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Checks whether the matcher is satisifed with the expression given to it.
    private def match?(actual : TestExpression(T)) forall T
      actual.value.has_value?(expected.value)
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description
      "has value #{expected.label}"
    end

    # Message displayed when the matcher isn't satisifed.
    #
    # This is only called when `#match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message(actual)
      "#{actual.label} does not have value #{expected.label}"
    end

    # Message displayed when the matcher isn't satisifed and is negated.
    # This is essentially what would satisfy the matcher if it wasn't negated.
    #
    # This is only called when `#does_not_match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message_when_negated(actual)
      "#{actual.label} has value #{expected.label}"
    end

    # Additional information about the match failure.
    # The return value is a NamedTuple with Strings for each value.
    private def values(actual)
      actual_value = actual.value
      set = actual_value.responds_to?(:values) ? actual_value.values : actual_value
      {
        value:  expected.value.inspect,
        actual: set.inspect,
      }
    end
  end
end
