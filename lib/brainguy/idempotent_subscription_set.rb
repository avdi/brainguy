require "brainguy/subscription_set"

module Brainguy
  class IdempotentSubscriptionSet < SubscriptionSet
    def initialize(*)
      super
      @event_log = []
    end

    def emit(*event_args)
      @event_log.push(event_args)
      super
    end

    def <<(subscription)
      super
      @event_log.each do |event_args|
        subscription.handle(@event_source,
                            event_args.first,
                            event_args.drop(1))
      end
    end
  end
end
