require "brainguy/subscription_set"
require "delegate"

module Brainguy
  # A wrapper for a {SubscriptionSet} that enables a "fluent API" by
  # returning `self` from each method.
  #
  # Enables code like this:
  #
  #   kitten.on(:purr) do
  #     # handle purr...
  #   end.on(:mew) do
  #     # handle mew...
  #   end
  class FluentSubscriptionSet < DelegateClass(SubscriptionSet)
    # (see SubscriptionSet#on)
    # @return `self`
    def on(*)
      super
      self
    end

    # (see SubscriptionSet#attach)
    # @return `self`
    def attach(*)
      super
      self
    end
  end
end
