require "../../spec_helper"

Spectator.describe Spectator::Double do
  Spectator::Double.define(EmptyDouble)
  Spectator::Double.define(FooBarDouble, "dbl-name", foo: 42, bar: "baz")

  # The subject `dbl` must be carefully used in sub-contexts, otherwise it pollutes parent scopes.
  # This changes the type of `dbl` to `Double+`, which produces a union of methods and their return types.
  context "plain double" do
    subject(dbl) { FooBarDouble.new }

    it "responds to defined messages" do
      aggregate_failures do
        expect(dbl.foo).to eq(42)
        expect(dbl.bar).to eq("baz")
      end
    end

    it "fails on undefined messages" do
      expect { dbl.baz }.to raise_error(Spectator::UnexpectedMessage, /baz/)
    end

    it "reports the name in errors" do
      expect { dbl.baz }.to raise_error(/"dbl-name"/)
    end

    it "reports arguments" do
      expect { dbl.baz(123, "qux", field: :value) }.to raise_error(Spectator::UnexpectedMessage, /\(123, "qux", field: :value\)/)
    end

    it "has a non-union return type" do
      aggregate_failures do
        expect(dbl.foo).to compile_as(Int32)
        expect(dbl.bar).to compile_as(String)
      end
    end

    it "uses nil for undefined messages" do
      expect { dbl.baz }.to compile_as(Nil)
    end

    context "blocks" do
      it "supports blocks" do
        aggregate_failures do
          expect(dbl.foo { nil }).to eq(42)
          expect(dbl.bar { nil }).to eq("baz")
        end
      end

      it "supports blocks and has non-union return types" do
        aggregate_failures do
          expect(dbl.foo { nil }).to compile_as(Int32)
          expect(dbl.bar { nil }).to compile_as(String)
        end
      end

      it "fails on undefined messages" do
        expect do
          dbl.baz { nil }
        end.to raise_error(Spectator::UnexpectedMessage, /baz/)
      end
    end
  end

  context "without a double name" do
    Spectator::Double.define(NamelessDouble, foo: 42)

    subject(dbl) { NamelessDouble.new }

    it "reports as anonymous" do
      expect { dbl.baz }.to raise_error(/anonymous/i)
    end
  end

  context "with abstract stubs and return type annotations" do
    Spectator::Double.define(TestDouble) do
      abstract_stub abstract def foo(value) : String
    end

    let(arguments) { Spectator::Arguments.capture(/foo/) }
    let(stub) { Spectator::ValueStub.new(:foo, "bar", arguments).as(Spectator::Stub) }
    subject(dbl) { TestDouble.new([stub]) }

    it "enforces the return type" do
      expect(dbl.foo("foobar")).to compile_as(String)
    end

    it "raises on non-matching arguments" do
      expect { dbl.foo("bar") }.to raise_error(Spectator::UnexpectedMessage, /foo/)
    end

    it "raises on non-matching stub" do
      stub = Spectator::ValueStub.new(:foo, 42, arguments).as(Spectator::Stub)
      dbl._spectator_define_stub(stub)
      expect { dbl.foo("foobar") }.to raise_error(TypeCastError, /String/)
    end
  end

  context "with nillable return type annotations" do
    Spectator::Double.define(TestDouble) do
      abstract_stub abstract def foo : String?
      abstract_stub abstract def bar : Nil
    end

    let(foo_stub) { Spectator::ValueStub.new(:foo, nil).as(Spectator::Stub) }
    let(bar_stub) { Spectator::ValueStub.new(:bar, nil).as(Spectator::Stub) }
    subject(dbl) { TestDouble.new([foo_stub, bar_stub]) }

    it "doesn't raise on nil" do
      aggregate_failures do
        expect(dbl.foo).to be_nil
        expect(dbl.bar).to be_nil
      end
    end
  end

  context "with common object methods" do
    subject(dbl) do
      EmptyDouble.new([
        Spectator::ValueStub.new(:"!=", false),
        Spectator::ValueStub.new(:"!~", false),
        Spectator::ValueStub.new(:"==", true),
        Spectator::ValueStub.new(:"===", true),
        Spectator::ValueStub.new(:"=~", nil),
        Spectator::ValueStub.new(:class, EmptyDouble),
        Spectator::ValueStub.new(:dup, EmptyDouble.new),
        Spectator::ValueStub.new(:"in?", true),
        Spectator::ValueStub.new(:inspect, "inspect"),
        Spectator::ValueStub.new(:itself, EmptyDouble.new),
        Spectator::ValueStub.new(:"not_nil!", EmptyDouble.new),
        Spectator::ValueStub.new(:pretty_inspect, "pretty_inspect"),
        Spectator::ValueStub.new(:tap, EmptyDouble.new),
        Spectator::ValueStub.new(:to_json, "to_json"),
        Spectator::ValueStub.new(:to_pretty_json, "to_pretty_json"),
        Spectator::ValueStub.new(:to_s, "to_s"),
        Spectator::ValueStub.new(:to_yaml, "to_yaml"),
        Spectator::ValueStub.new(:try, nil),
        Spectator::ValueStub.new(:object_id, 42_u64),
        Spectator::ValueStub.new(:"same?", true),
      ] of Spectator::Stub)
    end

    it "responds with defined messages" do
      aggregate_failures do
        expect(dbl.!=(42)).to be_false
        expect(dbl.!~(42)).to be_false
        expect(dbl.==(42)).to be_true
        expect(dbl.===(42)).to be_true
        expect(dbl.=~(42)).to be_nil
        expect(dbl.class).to eq(EmptyDouble)
        expect(dbl.dup).to be_a(EmptyDouble)
        expect(dbl.in?([42])).to eq(true)
        expect(dbl.in?(1, 2, 3)).to eq(true)
        expect(dbl.inspect).to eq("inspect")
        expect(dbl.itself).to be_a(EmptyDouble)
        expect(dbl.not_nil!).to be_a(EmptyDouble)
        expect(dbl.pretty_inspect).to eq("pretty_inspect")
        expect(dbl.tap { nil }).to be_a(EmptyDouble)
        expect(dbl.to_json).to eq("to_json")
        expect(dbl.to_pretty_json).to eq("to_pretty_json")
        expect(dbl.to_s).to eq("to_s")
        expect(dbl.to_yaml).to eq("to_yaml")
        expect(dbl.try { nil }).to be_nil
        expect(dbl.object_id).to eq(42_u64)
        expect(dbl.same?(dbl)).to be_true
        expect(dbl.same?(nil)).to be_true
      end
    end

    it "has a non-union return type" do
      expect(dbl.inspect).to compile_as(String)
    end
  end

  context "without common object methods" do
    subject(dbl) { EmptyDouble.new }

    it "returns original implementation with undefined messages" do
      io = IO::Memory.new
      pp = PrettyPrint.new(io)
      hasher = Crystal::Hasher.new
      aggregate_failures do
        expect(dbl.!=(42)).to be_true
        expect(dbl.!~(42)).to be_true
        expect(dbl.==(42)).to be_false
        expect(dbl.===(42)).to be_false
        expect(dbl.=~(42)).to be_nil
        expect(dbl.class).to eq(EmptyDouble)
        expect(dbl.dup).to be_a(EmptyDouble)
        expect(dbl.hash(hasher)).to be_a(Crystal::Hasher)
        expect(dbl.hash).to be_a(UInt64)
        expect(dbl.in?([42])).to be_false
        expect(dbl.in?(1, 2, 3)).to be_false
        expect(dbl.inspect).to contain("EmptyDouble")
        expect(dbl.itself).to be(dbl)
        expect(dbl.not_nil!).to be(dbl)
        expect(dbl.pretty_inspect).to contain("EmptyDouble")
        expect(dbl.pretty_print(pp)).to be_nil
        expect(dbl.tap { nil }).to be(dbl)
        expect(dbl.to_s).to contain("EmptyDouble")
        expect(dbl.to_s(io)).to be_nil
        expect(dbl.try { nil }).to be_nil
        expect(dbl.object_id).to be_a(UInt64)
        expect(dbl.same?(dbl)).to be_true
        expect(dbl.same?(nil)).to be_false
      end
    end

    it "reports arguments when they don't match" do
      expect { dbl.same?(123, :xyz) }.to raise_error(Spectator::UnexpectedMessage, /\(123, :xyz\)/)
    end
  end

  context "with arguments constraints" do
    let(arguments) { Spectator::Arguments.capture(/foo/) }

    context "without common object methods" do
      Spectator::Double.define(TestDouble) do
        abstract_stub abstract def foo(value) : String
        abstract_stub abstract def foo(value, & : -> _) : String
      end

      let(stub) { Spectator::ValueStub.new(:foo, "bar", arguments).as(Spectator::Stub) }
      subject(dbl) { TestDouble.new([stub]) }

      it "returns the response when constraint satisfied" do
        expect(dbl.foo("foobar")).to eq("bar")
      end

      it "raises an error when constraint unsatisfied" do
        expect { dbl.foo("baz") }.to raise_error(Spectator::UnexpectedMessage)
      end

      it "raises an error when argument count doesn't match" do
        expect { dbl.foo }.to raise_error(Spectator::UnexpectedMessage)
      end

      it "has a non-union return type" do
        expect(dbl.foo("foobar")).to compile_as(String)
      end

      it "ignores the block argument if not in the constraint" do
        expect(dbl.foo("foobar") { nil }).to eq("bar")
      end
    end

    context "with common object methods" do
      Spectator::Double.define(TestDouble) do
        stub abstract def same?(other : Reference) : Bool
      end

      let(stub) { Spectator::ValueStub.new(:"same?", true, arguments).as(Spectator::Stub) }
      subject(dbl) { TestDouble.new([stub]) }

      it "returns the response when constraint satisfied" do
        expect(dbl.same?("foobar")).to eq(true)
      end

      it "raises an error when constraint unsatisfied" do
        expect { dbl.same?("baz") }.to raise_error(Spectator::UnexpectedMessage)
      end

      it "raises an error when argument count doesn't match" do
        expect { dbl.same? }.to raise_error(Spectator::UnexpectedMessage)
      end

      it "has a non-union return type" do
        expect(dbl.same?("foobar")).to compile_as(Bool)
      end
    end
  end

  describe "#_spectator_define_stub" do
    subject(dbl) { FooBarDouble.new }
    let(stub3) { Spectator::ValueStub.new(:foo, 3) }
    let(stub5) { Spectator::ValueStub.new(:foo, 5) }
    let(stub7) { Spectator::ValueStub.new(:foo, 7, Spectator::Arguments.capture(:lucky)) }

    it "overrides an existing method" do
      expect { dbl._spectator_define_stub(stub3) }.to change { dbl.foo }.from(42).to(3)
    end

    it "replaces an existing stub" do
      dbl._spectator_define_stub(stub3)
      expect { dbl._spectator_define_stub(stub5) }.to change { dbl.foo }.from(3).to(5)
    end

    it "doesn't affect other methods" do
      expect { dbl._spectator_define_stub(stub5) }.to_not change { dbl.bar }
    end

    it "picks the correct stub based on arguments" do
      dbl._spectator_define_stub(stub5)
      dbl._spectator_define_stub(stub7)
      aggregate_failures do
        expect(dbl.foo).to eq(5)
        expect(dbl.foo(:lucky)).to eq(7)
      end
    end

    it "only uses a stub if an argument constraint is met" do
      dbl._spectator_define_stub(stub7)
      aggregate_failures do
        expect(dbl.foo).to eq(42)
        expect(dbl.foo(:lucky)).to eq(7)
      end
    end

    it "ignores the block argument if not in the constraint" do
      dbl._spectator_define_stub(stub5)
      dbl._spectator_define_stub(stub7)
      aggregate_failures do
        expect(dbl.foo { nil }).to eq(5)
        expect(dbl.foo(:lucky) { nil }).to eq(7)
      end
    end
  end

  describe "#_spectator_clear_stubs" do
    subject(dbl) { FooBarDouble.new }
    let(stub) { Spectator::ValueStub.new(:foo, 5) }

    before_each { dbl._spectator_define_stub(stub) }

    it "removes previously defined stubs" do
      expect { dbl._spectator_clear_stubs }.to change { dbl.foo }.from(5).to(42)
    end
  end

  describe "#_spectator_calls" do
    subject(dbl) { FooBarDouble.new }
    let(stub) { Spectator::ValueStub.new(:foo, 5) }

    before_each { dbl._spectator_define_stub(stub) }

    # Retrieves symbolic names of methods called on a double.
    def called_method_names(dbl)
      dbl._spectator_calls.map(&.method)
    end

    it "stores calls to stubbed methods" do
      expect { dbl.foo }.to change { called_method_names(dbl) }.from(%i[]).to(%i[foo])
    end

    it "stores multiple calls to the same stub" do
      dbl.foo
      expect { dbl.foo }.to change { called_method_names(dbl) }.from(%i[foo]).to(%i[foo foo])
    end

    it "stores calls to non-stubbed methods" do
      expect { dbl.baz }.to raise_error(Spectator::UnexpectedMessage, /baz/)
      expect(called_method_names(dbl)).to eq(%i[baz])
    end

    it "stores arguments for a call" do
      dbl.foo(42)
      args = Spectator::Arguments.capture(42)
      call = dbl._spectator_calls.first
      expect(call.arguments).to eq(args)
    end
  end
end
