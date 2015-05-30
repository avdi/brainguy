module Brainguy
  class Subscription
    include Comparable

    attr_reader :owner, :listener

    def initialize(owner, listener)
      @owner    = owner
      @listener = listener
    end

    def handle(event_source, event_name, extra_args)
      @listener.call(event_source, event_name, *extra_args)
    end

    def cancel
      @owner.delete(self)
    end

    def <=>(other)
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
