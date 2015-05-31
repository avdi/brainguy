require "brainguy/subscription_set"

module Brainguy
  class IdempotentSubscriptionSet < SubscriptionSet
    def initialize(*)
      super
      @event_log = []
    end

    def emit(event_name, *extra_args)
      @event_log.push(Event.new(event_name, @event_source, extra_args))
      super
    end

    def <<(subscription)
      super
      @event_log.each do |event|
        subscription.handle(event)
      end
    end

    alias_method :add, :<<
  end
end
