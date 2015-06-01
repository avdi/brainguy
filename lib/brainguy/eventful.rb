require "forwardable"
require "brainguy/subscription_set"

module Brainguy
  module Eventful
    extend Forwardable

    def events
      @brainguy_subscriptions ||= SubscriptionSet.new(self)
    end

    def_delegator :events, :on

    def_delegator :events, :emit
    private :emit
  end
end
