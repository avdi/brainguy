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
        class_eval %{
          def call(event)
            case event.name
            #{dispatch_table}
            end
          end
        }
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
      klass.regenerate_dispatch_method
    end
  end
end
