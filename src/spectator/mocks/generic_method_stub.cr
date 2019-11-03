require "./arguments"
require "./generic_arguments"
require "./method_call"
require "./method_stub"

module Spectator::Mocks
  abstract class GenericMethodStub(ReturnType) < MethodStub
    def initialize(name, source, @args : Arguments? = nil)
      super(name, source)
    end

    def callable?(call : GenericMethodCall(T, NT)) : Bool forall T, NT
      super && (!@args || @args === call.args)
    end

    abstract def call(args : GenericArguments(T, NT)) : ReturnType forall T, NT
  end
end
