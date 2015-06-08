module Brainguy
  # A value object that represents a single subscription to an event source.
  #
  # It ties together an event `source` to a `listener`. A listener is simply
  # some call-able object.
  class Subscription
    include Comparable

    # @!attribute [r] owner
    #   @return [SubscriptionSet] the owning {SubscriptionSet}
    # @!attribute [r] listener
    #   @return [:call] a callable listener object
    attr_reader :owner, :listener

    # @param owner [SubscriptionSet] the owning {SubscriptionSet}
    # @param listener [:call] a callable listener object
    def initialize(owner, listener)
      @owner    = owner
      @listener = listener
      freeze
    end

    # Dispatch `event` to the listener.
    # @param event [Event] the event to dispatch
    # @return whatever the listener returns
    def handle(event)
      @listener.call(event)
    end

    # Cancel the subscription (remove it from the `owner`)
    def cancel
      @owner.delete(self)
    end

    # Compare this to another subscription
    def <=>(other)
      return nil unless other.is_a?(Subscription)
      equality_components <=> other.equality_components
    end

    # The hash value is based on the identity (but not the state) of `owner`
    # and `listener`. Two `Subscription` objects with the same `owner` and
    # `listener` are considered to be equivalent.
    def hash
      [self.class, *equality_components].hash
    end

    # @!method eql?(other)
    # @param other [Subscription] the other subscription to compare to
    # @return [Boolean]
    alias_method :eql?, :==

    protected

    def equality_components
      [owner.object_id, listener.object_id]
    end
  end
end
