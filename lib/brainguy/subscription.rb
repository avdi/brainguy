module Brainguy
  # A value object that represents a single subscription to an event source.
  #
  # It ties together an event *source* to a *listener*. A listener is simply
  # some call-able object.
  class Subscription
    include Comparable

    attr_reader :owner, :listener

    def initialize(owner, listener)
      @owner    = owner
      @listener = listener
      freeze
    end

    def handle(event)
      @listener.call(event)
    end

    def cancel
      @owner.delete(self)
    end

    def <=>(other)
      return nil unless other.is_a?(Subscription)
      equality_components <=> other.equality_components
    end

    def hash
      [self.class, *equality_components].hash
    end

    alias_method :eql?, :==

    protected

    def equality_components
      [owner.object_id, listener.object_id]
    end
  end
end
