require "brainguy/emitter"
require "delegate"

module Brainguy
  # A wrapper for a {Emitter} that enables a "fluent API" by
  # returning `self` from each method.
  #
  # @example Enables code like this:
  #
  #   kitten.on(:purr) do
  #     # handle purr...
  #   end.on(:mew) do
  #     # handle mew...
  #   end
  class FluentEmitter < DelegateClass(Emitter)
    # (see Emitter#on)
    # @return `self`
    def on(*)
      super
      self
    end

    # (see Emitter#attach)
    # @return `self`
    def attach(*)
      super
      self
    end
  end
end
