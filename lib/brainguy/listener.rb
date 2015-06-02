require "brainguy/event"

module Brainguy
  module Listener
    module ClassMethods
      def method_added(method_name)
        if method_name.to_s =~ /\Ahandle_(.+)\z/
          brainguy_handler_methods[$1.to_sym] = method_name.to_sym
        end
        super
      end

      def brainguy_handler_methods
        @brainguy_handler_methods ||= {}
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    def call(event)
      if handler_method = self.class.brainguy_handler_methods[event.name]
        __send__(handler_method, event)
      end
    end
  end
end
