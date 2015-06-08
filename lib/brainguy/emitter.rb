require "delegate"
require "set"
require "brainguy/full_subscription"
require "brainguy/single_event_subscription"
require "brainguy/event"
require "brainguy/basic_notifier"
require "brainguy/open_observer"

module Brainguy
  # This object keeps track of all the listeners (observers) subscribed to a
  # particular event source object.
  class Emitter < DelegateClass(Set)
    DEFAULT_NOTIFIER = BasicNotifier.new

    # Create a new {Emitter} that shares its inner dataset with an
    # existing one. This exists so that it's possible to generate temporary
    # copies of a {Emitter} with different, specialized semantics;
    # for instance, an {IdempotentEmitter} that shares the same
    # set of subscriptions as an existing {Emitter}.
    # @param event_source [Object] the event-originating object
    # @param subscription_set [Emitter] the existing set to share
    #   subscriptions with
    # @return [Emitter]
    def self.new_from_existing(event_source, subscription_set)
      new(event_source, subscriptions: subscription_set.subscriptions)
    end

    # @param event_source [Object] the event-originating object
    # @option options [Set<Subscription>] :subscriptions (Set.new) the
    #   underlying set of subscriptions
    # @option options [:call] :notifier_maker a factory for notifiers.
    def initialize(event_source = self, options = {})
      super(options[:subscriptions] || Set.new)
      @event_source   = event_source
      @notifier_maker = options.fetch(:notifier_maker) {
        ->() { DEFAULT_NOTIFIER }
      }
    end

    # @return [Set<Subscription>] the underlying set of subscription objects
    def subscriptions
      __getobj__
    end

    # Attach a new object to listen for events. A listener is expected to be
    # call-able, and it will receive the `#call` message with an {Event} each
    # time one is emitted.
    # @param new_listener [:call]
    # @return [Subscription] a subscription object which can be used to
    #   cancel the subscription.
    def attach(new_listener)
      FullSubscription.new(self, new_listener).tap do |subscription|
        self << subscription
      end
    end

    # Detach a listener. This locates the subscription corresponding to the
    # given listener (if any), and removes it.
    # @param [:call] a listener to be unsubscribed
    # @return [void]
    def detach(listener)
      delete(FullSubscription.new(self, listener))
    end

    # Attach blocks of code to handle specific named events.
    # @overload on(name, &block)
    #   Attach a block to be called for a specific event. The block will be
    #   called with the event arguments (not the event object).
    #   @param name [Symbol]
    #   @param block [Proc] what to do when the event is emitted
    # @overload on(handlers)
    #   Attach multiple event-specific handlers at once.
    #   @param handlers [Hash{Symbol => [:call]}] a map of event names to
    #     callable handlers.
    # @return (see #attach)
    def on(name_or_handlers, &block)
      case name_or_handlers
      when Symbol
        attach_to_single_event(name_or_handlers, block)
      when Hash
        attach(OpenObserver.new(name_or_handlers))
      else
        fail ArgumentError, "Event name or Hash required"
      end
    end

    # Emit an event to be distributed to all interested listeners.
    # @param event_name [Symbol] the name of the event
    # @param extra_args [Array] any extra arguments that should accompany the
    #   event
    # @return the notifier's result value
    def emit(event_name, *extra_args)
      notifier = @notifier_maker.call
      each do |subscription|
        event = Event.new(event_name, @event_source, extra_args)
        notifier.notify(subscription, event)
      end
      notifier.result
    end

    private

    def attach_to_single_event(event_name, block)
      SingleEventSubscription.new(self, block, event_name).tap do
      |subscription|
        self << subscription
      end
    end
  end
end
