module Brainguy
  # A quick and dirty way to set up a reusable listener object. Like an
  # OpenObject, only for event listening!
  class OpenObserver
    # @param handlers [Hash{Symbol => [:call]}] a Hash of event names to
    #   callable handlers
    # @yield [self] if a block is given
    # @example Initializing and then adding handlers dynamically
    #   ol = OpenObserver.new
    #   ol.on_foo do
    #     # ...
    #   end
    #   ol.on_bar do
    #     # ...
    #   end
    # @example Initializing with a block
    #   listener = OpenObserver.new do |ol|
    #     ol.on_foo do
    #       # ...
    #     end
    #     ol.on_bar do
    #       # ...
    #     end
    #  end
    # @example Initializing from a hash
    #   listener = OpenObserver.new(foo: ->{...}, bar: ->{...})
    def initialize(handlers = {})
      @handlers = handlers
      yield self if block_given?
    end

    # Dispatch the event to the appropriate handler, if one has been set.
    # Events without handlers are ignored.
    # @param event [Event] the event to be handled
    def call(event)
      if (handler = @handlers[event.name])
        handler.call(event)
      end
    end

    # Enable setting up event handlers dynamically using `on_*` message sends.
    # @example
    #   ol = OpenObserver.new
    #   ol.on_foo do
    #     # ...
    #   end
    #   ol.on_bar do
    #     # ...
    #   end
    def method_missing(method_name, *_args, &block)
      if method_name.to_s =~ /\Aon_(.+)/
        @handlers[$1.to_sym] = block
        self
      else
        super
      end
    end

    # true if the method starts with `on_`
    # @return [Boolean]
    def respond_to_missing?(method_name, _include_private)
      method_name.to_s =~ /\Aon_./
    end
  end
end
