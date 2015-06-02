module Brainguy
  class OpenListener
    def initialize(handlers = {})
      @handlers = handlers
    end

    def call(event_source, event_name, *event_args)
      if handler = @handlers[event_name]
        handler.call(event_source, event_name, *event_args)
      end
    end

    def method_missing(method_name, *_args, &block)
      if method_name.to_s =~ /\Aon_(.+)/
        @handlers[$1.to_sym] = block
        self
      else
        super
      end
    end

    def respond_to_missing?(method_name, _include_private)
      method_name.to_s =~ /\Aon_./
    end
  end
end
