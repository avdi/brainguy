require "delegate"
require "brainguy/full_subscription"
require "brainguy/single_event_subscription"
require "brainguy/event"
require "brainguy/basic_notifier"

module Brainguy
  class SubscriptionSet < DelegateClass(Set)
    DEFAULT_NOTIFIER = BasicNotifier.new

    def initialize(event_source, options = {})
      super(Set.new)
      @event_source   = event_source
      @notifier_maker = options.fetch(:notifier_maker) {
        ->() { DEFAULT_NOTIFIER }
      }
    end

    def attach(new_listener)
      FullSubscription.new(self, new_listener).tap do |subscription|
        self << subscription
      end
    end

    def detach(listener)
      delete(FullSubscription.new(self, listener))
    end

    def on(event_name, &block)
      SingleEventSubscription.new(self, block, event_name).tap do |subscription|
        self << subscription
      end
    end

    def emit(event_name, *extra_args)
      notifier = @notifier_maker.call
      each do |subscription|
        event = Event.new(event_name, @event_source, extra_args)
        notifier.notify(subscription, event)
      end
      notifier.result
    end
  end
end
