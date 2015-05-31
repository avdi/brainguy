require "brainguy/subscription"

module Brainguy
  class SingleEventSubscription < Subscription
    def initialize(owner, listener, subscribed_event_name)
      @subscribed_event_name = subscribed_event_name
      super(owner, listener)
    end

    def handle(event)
      return unless event.name == @subscribed_event_name
      super
    end

    def equality_components
      super + [@subscribed_event_name]
    end
  end
end
