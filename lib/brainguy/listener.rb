require "brainguy/event"

module Brainguy
  module Listener
    module ClassMethods
      HANDLER_METHOD_PATTERN = /\Aon_(.+)\z/

      def method_added(method_name)
        if method_name.to_s =~ HANDLER_METHOD_PATTERN
          regenerate_dispatch_method
        end
        super
      end

      def regenerate_dispatch_method
        dispatch_table = instance_methods
                             .map(&:to_s)
                             .grep(HANDLER_METHOD_PATTERN) { |method_name|
          event_name = $1
          "when :#{event_name} then #{method_name}(event)"
        }.join("\n")
        code = %{
          def call(event)
            case event.name
            #{dispatch_table}
            # Note: following case is mainly here to keep the parser happy
            # when there are no other cases (i.e. no handler methods defined
            # yet).
            when nil then fail ArgumentError, "Event cannot be nil"
            else event_handler_missing(event)
            end
          end
        }
        class_eval code
      rescue SyntaxError => error
        # SyntaxErrors suck when you can't look at the syntax
        error.message << "\n\nGenerated code:\n\n#{code}"
        raise error
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
      klass.regenerate_dispatch_method
    end

    def event_handler_missing(event)
      # just a placeholder
    end
  end
end
