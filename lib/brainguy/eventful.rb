require "forwardable"
require "brainguy/subscription_set"

module Brainguy
  module Eventful
    extend Forwardable

    def events
      @brainguy_subscriptions ||= SubscriptionSet.new(self)
    end

    def with_subscription_scope(listener_block, &block)
      Brainguy.with_subscription_scope(self, listener_block, events, &block)
    end

    def_delegator :events, :on

    def_delegator :events, :emit
    private :emit
  end
end
