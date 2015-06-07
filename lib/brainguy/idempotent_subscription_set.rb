require "brainguy/subscription_set"

module Brainguy
  # A type of {SubscriptionSet} that records and "plays back" events to new
  # listeners. That way a listener will never miss an event, even if it
  # subscribes late.
  #
  # This class is probably best used in short-lived scopes, since the log of
  # events will continually grow.
  class IdempotentSubscriptionSet < SubscriptionSet
    # (see SubscriptionSet#initialize)
    def initialize(*)
      super
      @event_log = []
    end

    # Emit an event and record it in the log.
    # @event_name (see SubscriptionSet#emit)
    # @extra_args (see SubscriptionSet#emit)
    # @return (see SubscriptionSet#emit)
    def emit(event_name, *extra_args)
      @event_log.push(Event.new(event_name, @event_source, extra_args))
      super
    end

    # Add a new subscription, and immediately play back any missed events to
    # it.
    #
    # @param subscription (see SubscriptionSet#<<)
    # @return (see SubscriptionSet#<<)
    def <<(subscription)
      super
      @event_log.each do |event|
        subscription.handle(event)
      end
    end

    alias_method :add, :<<
  end
end
