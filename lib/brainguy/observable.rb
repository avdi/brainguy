require "forwardable"
require "brainguy/emitter"

module Brainguy
  # A convenience module for making client classes observable.
  module Observable
    extend Forwardable

    # @return [Emitter] the {Emitter} managing all
    #   subscriptions to this object's events.
    def events
      @brainguy_subscriptions ||= Emitter.new(self)
    end

    # Create a temporary scope for transient subscriptions. Useful for
    # making a single method listenable. See {file:README.md} for usage
    # examples.
    #
    # @param listener_block (see Brainguy.with_subscription_scope)
    def with_subscription_scope(listener_block, &block)
      Brainguy.with_subscription_scope(self, listener_block, events, &block)
    end

    # @!method on(name_or_handlers, &block)
    # (see {Emitter#on})
    def_delegator :events, :on

    # @!method emit
    # (see {Emitter#emit})
    def_delegator :events, :emit
    private :emit
  end
end
