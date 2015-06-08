require "brainguy/subscription"

module Brainguy
  # A subscription to a single type (name) of event. The `listener` will only
  # be notified if the event name matches `subscribed_event_name`.
  #
  # See {Emitter#on} for where this class is used.
  class SingleEventSubscription < Subscription
    # @param owner [Emitter] the owning {Emitter}
    # @param listener [:call] some callable that should be called when the
    #   named event occurs
    # @param subscribed_event_name [Symbol] the event to subscribe to
    def initialize(owner, listener, subscribed_event_name)
      @subscribed_event_name = subscribed_event_name
      super(owner, listener)
    end

    # Call listener if the event name is the one being subscribed to.
    # @param event [Event] the event to (maybe) dispatch
    def handle(event)
      return unless event.name == @subscribed_event_name
      @listener.call(*event.args)
    end

    protected

    def equality_components
      super + [@subscribed_event_name]
    end
  end
end
