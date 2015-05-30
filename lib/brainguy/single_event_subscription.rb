require "brainguy/subscription"

module Brainguy
  class SingleEventSubscription < Subscription
    def initialize(owner, listener, subscribed_event_name)
      super(owner, listener)
      @subscribed_event_name = subscribed_event_name
    end

    def handle(event_source, event_name, extra_args)
      return unless event_name == @subscribed_event_name
      super
    end
  end
end
