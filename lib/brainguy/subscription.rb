module Brainguy
  class Subscription
    attr_reader :listener

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
  end
end
