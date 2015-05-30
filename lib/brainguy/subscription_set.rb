require "delegate"
require "brainguy/full_subscription"
require "brainguy/single_event_subscription"

module Brainguy
  class SubscriptionSet < DelegateClass(Set)
    def initialize
      super(Set.new)
    end

    def add_listener(new_listener)
      FullSubscription.new(self, new_listener).tap do |subscription|
        self << subscription
      end
    end

    def on(event_name, &block)
      SingleEventSubscription.new(self, block, event_name).tap do |subscription|
        self << subscription
      end
    end
  end
end
