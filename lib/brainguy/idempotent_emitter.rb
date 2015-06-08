require "brainguy/emitter"

module Brainguy
  # A type of {Emitter} that records and "plays back" events to new
  # listeners. That way a listener will never miss an event, even if it
  # subscribes late.
  #
  # This class is probably best used in short-lived scopes, since the log of
  # events will continually grow.
  class IdempotentEmitter < Emitter
    # (see Emitter#initialize)
    def initialize(*)
      super
      @event_log = []
    end

    # Emit an event and record it in the log.
    # @event_name (see Emitter#emit)
    # @extra_args (see Emitter#emit)
    # @return (see Emitter#emit)
    def emit(event_name, *extra_args)
      @event_log.push(Event.new(event_name, @event_source, extra_args))
      super
    end

    # Add a new subscription, and immediately play back any missed events to
    # it.
    #
    # @param subscription (see Emitter#<<)
    # @return (see Emitter#<<)
    def <<(subscription)
      super
      @event_log.each do |event|
        subscription.handle(event)
      end
    end

    alias_method :add, :<<
  end
end
