module Brainguy
  module Eventful
    def events
      @brainguy_subscriptions ||= SubscriptionSet.new(self)
    end
  end
end
