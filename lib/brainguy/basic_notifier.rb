module Brainguy
  # A notifier encapsulates various strategies for notifying subscriptions of
  # events. This is the most basic form of notifier. It just passes the event
  # on with no extra logic.
  class BasicNotifier
    # Notify a subscription of an event
    #
    # @return (see Subscription#handle)
    def notify(subscription, event)
      subscription.handle(event)
    end

    # Some notifiers have interesting results. This one just returns nil.
    # @return nil
    def result
      nil
    end
  end
end
