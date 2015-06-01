require "brainguy/eventful"
require "brainguy/manifest_subscription_set"

module Brainguy
  class ManifestlyEventful < Module
    def initialize(*known_events)
      super() do
        include Eventful
        define_method :events do
          @manifest_events ||= ManifestSubscriptionSet.new(super()).tap do |set|
            set.known_types.concat(known_events)
          end
        end
      end
    end
  end
end
