require "brainguy/subscription_set"
require "delegate"

module Brainguy
  class FluentSubscriptionSet < DelegateClass(SubscriptionSet)
    def on(*)
      super
      self
    end

    def attach(*)
      super
      self
    end
  end
end
