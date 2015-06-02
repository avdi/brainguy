require "brainguy/subscription_set"
require "delegate"

module Brainguy
  class SubscriptionScope < DelegateClass(SubscriptionSet)
    def self.open(subscription_set)
      scope = self.new(subscription_set)
      yield scope
    ensure
      scope.close
    end

    def initialize(subscription_set)
      super(subscription_set)
      @subscriptions = []
    end

    def on(*)
      super.tap do |subscription|
        @subscriptions << subscription
      end
    end

    def attach(*)
      super.tap do |subscription|
        @subscriptions << subscription
      end
    end

    def close
      @subscriptions.each(&:cancel)
      @subscriptions.clear
    end
  end

  class SubscriptionSet
    def with_subscription_scope(&block)
      SubscriptionScope.open(self, &block)
    end
  end
end
