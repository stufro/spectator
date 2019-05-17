require "../matchers"

module Spectator::DSL
  # Methods for defining matchers for expectations.
  module MatcherDSL
    # Indicates that some value should equal another.
    # The == operator is used for this check.
    # The value passed to this method is the expected value.
    #
    # Example:
    # ```
    # expect(1 + 2).to eq(3)
    # ```
    macro eq(expected)
      ::Spectator::Matchers::EqualityMatcher.new({{expected}}, {{expected.stringify}})
    end

    # Indicates that some value should not equal another.
    # The != operator is used for this check.
    # The value passed to this method is the unexpected value.
    #
    # Example:
    # ```
    # expect(1 + 2).to ne(5)
    # ```
    macro ne(expected)
      ::Spectator::Matchers::InequalityMatcher.new({{expected}}, {{expected.stringify}})
    end

    # Indicates that some value when compared to another satisfies an operator.
    # An operator can follow, such as: <, <=, >, or >=.
    # See `Spectator::Matchers::TruthyMatcher` for a full list of operators.
    #
    # Examples:
    # ```
    # expect(1 + 1).to be > 1
    # expect(5).to be >= 3
    # ```
    #
    # Additionally, a value can just "be" truthy by omitting an operator.
    # ```
    # expect("foo").to be
    # # is the same as:
    # expect("foo").to be_truthy
    # ```
    macro be
      ::Spectator::Matchers::TruthyMatcher.new(true)
    end

    # Indicates that some object should be the same as another.
    # This checks if two references are the same.
    # The `Reference#same?` method is used for this check.
    #
    # Examples:
    # ```
    # obj = "foobar"
    # expect(obj).to be(obj)
    # expect(obj.dup).to_not be(obj)
    # ```
    macro be(expected)
      ::Spectator::Matchers::ReferenceMatcher.new({{expected}}, {{expected.stringify}})
    end

    # Indicates that some value should be of a specified type.
    # The `Object#is_a?` method is used for this check.
    # A type name or type union should be used for *expected*.
    #
    # Examples:
    # ```
    # expect("foo").to be_a(String)
    #
    # x = Random.rand(2) == 0 ? "foobar" : 5
    # expect(x).to be_a(Int32 | String)
    # ```
    macro be_a(expected)
      ::Spectator::Matchers::TypeMatcher({{expected}}).new
    end

    # Indicates that some value should be of a specified type.
    # The `Object#is_a?` method is used for this check.
    # A type name or type union should be used for *expected*.
    # This method is identical to `#be_a`,
    # and exists just to improve grammar.
    #
    # Examples:
    # ```
    # expect(123).to be_an(Int32)
    # ```
    macro be_an(expected)
      be_a({{expected}})
    end

    # Indicates that some value should respond to a method call.
    # One or more method names can be provided.
    #
    # Examples:
    # ```
    # expect("foobar").to respond_to(:downcase)
    # expect(%i[a b c]).to respond_to(:size, :first)
    # ```
    macro respond_to(*expected)
      ::Spectator::Matchers::RespondMatcher({% begin %}NamedTuple(
        {% for method in expected %}
        {{method.id.stringify}}: Nil,
        {% end %}
        ){% end %}).new
    end

    # Indicates that some value should be less than another.
    # The < operator is used for this check.
    # The value passed to this method is the value expected to be larger.
    #
    # Example:
    # ```
    # expect(3 - 1).to be_lt(3)
    # ```
    macro be_lt(expected)
      ::Spectator::Matchers::LessThanMatcher.new({{expected}}, {{expected.stringify}})
    end

    # Indicates that some value should be less than or equal to another.
    # The <= operator is used for this check.
    # The value passed to this method is the value expected to be larger or equal.
    #
    # Example:
    # ```
    # expect(3 - 1).to be_le(3)
    # ```
    macro be_le(expected)
      ::Spectator::Matchers::LessThanEqualMatcher.new({{expected}}, {{expected.stringify}})
    end

    # Indicates that some value should be greater than another.
    # The > operator is used for this check.
    # The value passed to this method is the value expected to be smaller.
    #
    # Example:
    # ```
    # expect(3 + 1).to be_gt(3)
    # ```
    macro be_gt(expected)
      ::Spectator::Matchers::GreaterThanMatcher.new({{expected}}, {{expected.stringify}})
    end

    # Indicates that some value should be greater than or equal to another.
    # The >= operator is used for this check.
    # The value passed to this method is the value expected to be smaller or equal.
    #
    # Example:
    # ```
    # expect(3 + 1).to be_ge(3)
    # ```
    macro be_ge(expected)
      ::Spectator::Matchers::GreaterThanEqualMatcher.new({{expected}}, {{expected.stringify}})
    end

    # Indicates that some value should match another.
    # The === (case equality) operator is used for this check.
    # Typically a regular expression is used.
    # This has identical behavior as a "when" condition in a case block.
    #
    # Examples:
    # ```
    # expect("foo").to match(/foo|bar/)
    # expect("BAR").to match(/foo|bar/i)
    # expect(1 + 2).to match(3)
    # expect(5).to match(Int32) # Using `#be_a` instead is recommened here.
    # expect({:foo, 5}).to match({Symbol, Int32})
    # ```
    macro match(expected)
      ::Spectator::Matchers::CaseMatcher.new({{expected}}, {{expected.stringify}})
    end

    # Indicates that some value should be true.
    #
    # Examples:
    # ```
    # expect(nil.nil?).to be_true
    # expect(%i[a b c].any?).to be_true
    # ```
    macro be_true
      eq(true)
    end

    # Indicates that some value should be false.
    #
    # Examples:
    # ```
    # expect("foo".nil?).to be_false
    # expect(%i[a b c].empty?).to be_false
    # ```
    macro be_false
      eq(false)
    end

    # Indicates that some value should be truthy.
    # This means that the value is not false and not nil.
    #
    # Examples:
    # ```
    # expect(123).to be_truthy
    # expect(true).to be_truthy
    # ```
    macro be_truthy
      ::Spectator::Matchers::TruthyMatcher.new(true)
    end

    # Indicates that some value should be falsey.
    # This means that the value is either false or nil.
    #
    # Examples:
    # ```
    # expect(false).to be_falsey
    # expect(nil).to be_falsey
    # ```
    macro be_falsey
      ::Spectator::Matchers::TruthyMatcher.new(false)
    end

    # Indicates that some value should be contained within another.
    # This checker can be used in one of two ways.
    #
    # The first: the *expected* argument can be anything
    # that implements the `includes?` method.
    # This is typically a `Range`, but can also be `Enumerable`.
    #
    # Examples:
    # ```
    # expect(:foo).to be_within(%i[foo bar baz])
    # expect(7).to be_within(1..10)
    # ```
    #
    # The other way is to use this is with the "of" keyword.
    # This creates a lower and upper bound
    # centered around the value of the *expected* argument.
    # This usage is helpful for comparisons on floating-point numbers.
    #
    # Examples:
    # ```
    # expect(50.0).to be_within(0.01).of(50.0)
    # expect(speed).to be_within(5).of(speed_limit)
    # ```
    #
    # NOTE: The of suffix must be used
    # if the *expected* argument does not implement an includes? method.
    #
    # Additionally, for this second usage,
    # an "inclusive" or "exclusive" suffix can be added.
    # These modify the upper-bound on the range being checked against.
    # By default, the range is inclusive.
    #
    # Examples:
    # ```
    # expect(days).to be_within(1).of(30).inclusive # 29, 30, or 31
    # expect(100).to be_within(2).of(99).exclusive  # 97, 98, 99, or 100 (not 101)
    # ```
    #
    # NOTE: Do not attempt to mix the two use cases.
    # It likely won't work and will result in a compilation error.
    macro be_within(expected)
      ::Spectator::Matchers::RangeMatcher.new({{expected}}, {{expected.stringify}})
    end

    # Indicates that some value should be between a lower and upper-bound.
    #
    # Example:
    # ```
    # expect(7).to be_between(1, 10)
    # ```
    #
    # Additionally, an "inclusive" or "exclusive" suffix can be added.
    # These modify the upper-bound on the range being checked against.
    # By default, the range is inclusive.
    #
    # Examples:
    # ```
    # expect(days).to be_between(28, 31).inclusive # 28, 29, 30, or 31
    # expect(100).to be_between(97, 101).exclusive # 97, 98, 99, or 100 (not 101)
    # ```
    macro be_between(min, max)
      :Spectator::Matchers::RangeMatcher.new(
        Range.new({{min}}, {{max}}),
        [{{min.stringify}}, {{max.stringify}}].join(" to ")
      )
    end

    # Indicates that some value should be within a delta of an expected value.
    #
    # Example:
    # ```
    # expect(pi).to be_close(3.14159265359, 0.0000001)
    # ```
    #
    # This is functionly equivalent to:
    # ```
    # be_within(expected).of(delta)
    # ```
    macro be_close(expected, delta)
      be_within({{delta}}).of({{expected}})
    end

    # Indicates that some value should or should not be nil.
    #
    # Examples:
    # ```
    # expect(error).to be_nil
    # expect(input).to_not be_nil
    # ```
    macro be_nil
      ::Spectator::Matchers::NilMatcher.new
    end

    # Indicates that some collection should be empty.
    #
    # Example:
    # ```
    # expect([]).to be_empty
    # ```
    macro be_empty
      ::Spectator::Matchers::EmptyMatcher.new
    end

    # Indicates that some value or set should start with another value.
    # This is typically used on a `String` or `Array` (any `Enumerable` works).
    # The *expected* argument can be a `String`, `Char`, or `Regex`
    # when the actual type (being comapred against) is a `String`.
    # For `Enumerable` types, only the first item is inspected.
    # It is compared with the === operator,
    # so that values, types, regular expressions, and others can be tested.
    #
    # Examples:
    # ```
    # expect("foobar").to start_with("foo")
    # expect("foobar").to start_with('f')
    # expect("FOOBAR").to start_with(/foo/i)
    #
    # expect(%i[a b c]).to start_with(:a)
    # expect(%i[a b c]).to start_with(Symbol)
    # expect(%w[foo bar]).to start_with(/foo/)
    # ```
    macro start_with(expected)
      ::Spectator::Matchers::StartWithMatcher.new({{expected}}, {{expected.stringify}})
    end

    # Indicates that some value or set should end with another value.
    # This is typically used on a `String` or `Array` (any `Indexable` works).
    # The *expected* argument can be a `String`, `Char`, or `Regex`
    # when the actual type (being comapred against) is a `String`.
    # For `Indexable` types, only the last item is inspected.
    # It is compared with the === operator,
    # so that values, types, regular expressions, and others can be tested.
    #
    # Examples:
    # ```
    # expect("foobar").to end_with("bar")
    # expect("foobar").to end_with('r')
    # expect("FOOBAR").to end_with(/bar/i)
    #
    # expect(%i[a b c]).to end_with(:c)
    # expect(%i[a b c]).to end_with(Symbol)
    # expect(%w[foo bar]).to end_with(/bar/)
    # ```
    macro end_with(expected)
      ::Spectator::Matchers::EndWithMatcher.new({{expected}}, {{expected.stringify}})
    end

    # Indicates that some value or set should contain another value.
    # This is typically used on a `String` or `Array` (any `Enumerable` works).
    # The *expected* argument can be a `String` or `Char`
    # when the actual type (being comapred against) is a `String`.
    # For `Enumerable` types, items are compared using the underying implementation.
    # In both cases, the `includes?` method is used.
    #
    # Examples:
    # ```
    # expect("foobar").to contain("foo")
    # expect("foobar").to contain('o')
    # expect(%i[a b c]).to contain(:b)
    # ```
    #
    # Additionally, multiple arguments can be specified.
    # ```
    # expect("foobarbaz").to contain("foo", "bar")
    # expect(%i[a b c]).to contain(:a, :b)
    # ```
    macro contain(*expected)
      ::Spectator::Matchers::ContainMatcher.new({{expected}}, {{expected.splat.stringify}})
    end

    # Indicates that some value or set should contain another value.
    # This is similar to `#contain`, but uses a different method for matching.
    # Typically a `String` or `Array` (any `Enumerable` works) is checked against.
    # The *expected* argument can be a `String` or `Char`
    # when the actual type (being comapred against) is a `String`.
    # The `includes?` method is used for this case.
    # For `Enumerable` types, each item is inspected until one matches.
    # The === operator is used for this case, which allows for equality, type, regex, and other matches.
    #
    # Examples:
    # ```
    # expect("foobar").to have("foo")
    # expect("foobar").to have('o')
    #
    # expect(%i[a b c]).to have(:b)
    # expect(%w[FOO BAR BAZ]).to have(/bar/i)
    # expect([1, 2, 3, :a, :b, :c]).to have(Int32)
    # ```
    #
    # Additionally, multiple arguments can be specified.
    # ```
    # expect("foobarbaz").to have("foo", "bar")
    # expect(%i[a b c]).to have(:a, :b)
    # expect(%w[FOO BAR BAZ]).to have(/foo/i, String)
    # ```
    macro have(*expected)
      ::Spectator::Matchers::HaveMatcher.new({{expected}}, {{expected.splat.stringify}})
    end

    # Indicates that some set, such as a `Hash`, has a given key.
    # The `has_key?` method is used for this check.
    #
    # Examples:
    # ```
    # expect({foo: "bar"}).to have_key(:foo)
    # expect({"lucky" => 7}).to have_key("lucky")
    # ```
    macro have_key(expected)
      ::Spectator::Matchers::HaveKeyMatcher.new({{expected}}, {{expected.stringify}})
    end

    # ditto
    macro has_key(expected)
      have_key({{expected}})
    end

    # Indicates that some set, such as a `Hash`, has a given value.
    # The `has_value?` method is used for this check.
    #
    # Examples:
    # ```
    # expect({foo: "bar"}).to have_value("bar")
    # expect({"lucky" => 7}).to have_value(7)
    # ```
    macro have_value(expected)
      ::Spectator::Matchers::HaveValueMatcher.new({{expected}}, {{expected.stringify}})
    end

    # ditto
    macro has_value(expected)
      have_value({{expected}})
    end

    # Indicates that some set should contain some values in exact order.
    #
    # Example:
    # ```
    # expect([1, 2, 3]).to contain_exactly(1, 2, 3)
    # ```
    macro contain_exactly(*expected)
      ::Spectator::Matchers::ArrayMatcher.new({{expected}}, {{expected.stringify}})
    end

    # Indicates that some set should contain the same values in exact order as another set.
    #
    # Example:
    # ```
    # expect([1, 2, 3]).to match_array([1, 2, 3])
    # ```
    macro match_array(expected)
      ::Spectator::Matchers::ArrayMatcher.new({{expected}}, {{expected.stringify}})
    end

    # Indicates that some value should have a set of attributes matching some conditions.
    # A list of named arguments are expected.
    # The names correspond to the attributes in the instance to check.
    # The values are conditions to check with the === operator against the attribute's value.
    #
    # Examples:
    # ```
    # expect("foobar").to have_attributes(size: 6, upcase: "FOOBAR")
    # expect(%i[a b c]).to have_attributes(size: 1..5, first: Symbol)
    # ```
    macro have_attributes(**expected)
      ::Spectator::Matchers::AttributesMatcher.new({{expected}}, {{expected.double_splat.stringify}})
    end

    # Indicates that some block should raise an error.
    #
    # Examples:
    # ```
    # expect { raise "foobar" }.to raise_error
    # ```
    macro raise_error
      ::Spectator::Matchers::ExceptionMatcher(Exception, Nil).new
    end

    # Indicates that some block should raise an error with a given message or type.
    # The *type_or_message* parameter should be an exception type
    # or a string or regex to match the exception's message against.
    #
    # Examples:
    # ```
    # hash = {"foo" => "bar"}
    # expect { hash["baz"] }.to raise_error(KeyError)
    # expect { hash["baz"] }.to raise_error(/baz/)
    # expect { raise "foobar" }.to raise_error("foobar")
    # ```
    macro raise_error(type_or_message)
      ::Spectator::Matchers::ExceptionMatcher.create({{type_or_message}}, {{type_or_message.stringify}})
    end

    # Indicates that some block should raise an error with a given message and type.
    # The *type* is the exception type expected to be raised.
    # The *message* is a string or regex to match to exception message against.
    #
    # Examples:
    # ```
    # hash = {"foo" => "bar"}
    # expect { hash["baz"] }.to raise_error(KeyError, /baz/)
    # expect { raise ArgumentError.new("foobar") }.to raise_error(ArgumentError, "foobar")
    # ```
    macro raise_error(type, message)
      ::Spectator::Matchers::ExceptionMatcher.create({{type}}, {{message}}, {{message.stringify}})
    end

    # Indicates that some block should raise an error.
    #
    # Examples:
    # ```
    # expect_raises { raise "foobar" }
    # ```
    macro expect_raises
      expect {{block}}.to raise_error
    end

    # Indicates that some block should raise an error with a given type.
    # The *type* parameter should be an exception type.
    #
    # Examples:
    # ```
    # hash = {"foo" => "bar"}
    # expect_raises(KeyError) { hash["baz"] }.to raise_error(KeyError)
    # ```
    macro expect_raises(type, &block)
      expect {{block}}.to raise_error({{type}})
    end

    # Indicates that some block should raise an error with a given message and type.
    # The *type* is the exception type expected to be raised.
    # The *message* is a string or regex to match to exception message against.
    # This method is included for compatibility with Crystal's default spec.
    #
    # Examples:
    # ```
    # hash = {"foo" => "bar"}
    # expect_raises(KeyError, /baz/) { hash["baz"] }
    # expect_raises(ArgumentError, "foobar") { raise ArgumentError.new("foobar") }
    # ```
    macro expect_raises(type, message, &block)
      expect {{block}}.to raise_error({{type}}, {{message}})
    end

    # Used to create predicate matchers.
    # Any missing method that starts with 'be_' will be handled.
    # All other method names will be ignored and raise a compile-time error.
    #
    # This can be used to simply check a predicate method that ends in '?'.
    # For instance:
    # ```
    # expect("foobar").to be_ascii_only
    # # Is equivalent to:
    # expect("foobar".ascii_only?).to be_true
    # ```
    macro method_missing(call)
      {% if call.name.starts_with?("be_") %}
      {% method_name = call.name[3..-1] %} # Remove be_ prefix.
      ::Spectator::Matchers::PredicateMatcher(NamedTuple({{method_name}}: Nil)).new
      {% else %}
      {% raise "Undefined local variable or method '#{call}'" %}
      {% end %}
    end
  end
end
