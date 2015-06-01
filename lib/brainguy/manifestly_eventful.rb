require "brainguy/eventful"
require "brainguy/manifest_subscription_set"

module Brainguy
  class ManifestlyEventful < Module
    # Look out, this gets a bit gnarly.
    def initialize(*known_events)
      # Define the module body
      super() do
        # First off, let's make sure we have basic Eventful functionality
        include Eventful

        # Now, we override #events to wrap it in some extra goodness
        define_method :events do

          # Let's see what the current subscription set object is
          subscription_set = super()

          # If there is already another ManifestlyEventful included further
          # up the chain...
          if subscription_set.is_a?(ManifestSubscriptionSet)
            # just add our event types to its subscription set
            subscription_set.known_types.concat(known_events)
          # But if this is the first ManifestlyEventful included...
          else
            # Wrap the subscription set in a ManifestSubscriptionSet
            @brainguy_events = ManifestSubscriptionSet.new(subscription_set)
            # Set up the known event types
            @brainguy_events.known_types.concat(known_events)
          end

          # No need to do all this every time. Once we've set everything up,
          # redefine the method on a per-instance level to be a simple getter.
          define_singleton_method :events do
            @brainguy_events
          end
          # Don't forget to return a value the first time around
          @brainguy_events
        end
      end
    end
  end
end
