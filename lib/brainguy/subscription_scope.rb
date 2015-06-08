require "brainguy/emitter"
require "delegate"

module Brainguy
  # A scope for subscriptions with a limited lifetime.
  #
  # Sometimes it's useful to have a set of subscriptions with a limited
  # lifetime. For instance, a set of observers which are only valid over the
  # course of a single method call. This class wraps an existing
  # {Emitter}, and exposes the same API. But when a client sends the
  # `#close` message, all listeners subscribed through this object will be
  # immediately unsubscribed.
  class SubscriptionScope < DelegateClass(Emitter)

    # Create a new scope and yield it to the block. Closes the scope
    # (unsubscribing any listeners attached using the scope) at the end of
    # block execution
    # @param (see #initialize)
    # @yield [SubscriptionScope] the subscription scope
    def self.open(subscription_set)
      scope = self.new(subscription_set)
      yield scope
    ensure
      scope.close
    end

    # @param subscription_set [Emitter] the subscription set to wrap
    def initialize(subscription_set)
      super(subscription_set)
      @subscriptions = []
    end

    # (see Emitter#on)
    def on(*)
      super.tap do |subscription|
        @subscriptions << subscription
      end
    end

    # (see Emitter#attach)
    def attach(*)
      super.tap do |subscription|
        @subscriptions << subscription
      end
    end

    # Detach every listener that was attached via this scope.
    # @return [void]
    def close
      @subscriptions.each(&:cancel)
      @subscriptions.clear
    end
  end

  class Emitter
    # @yield [SubscriptionScope] a temporary subscription scope layered on top
    #   of this {Emitter}
    def with_subscription_scope(&block)
      SubscriptionScope.open(self, &block)
    end
  end
end
