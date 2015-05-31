module Brainguy
  class BasicNotifier
    def notify(subscription, event)
      subscription.handle(event)
    end

    def result
      nil
    end
  end
end
