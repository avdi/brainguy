require "brainguy/subscription_set"
require "delegate"

module Brainguy
  class UnknownEvent < StandardError
  end

  class ManifestSubscriptionSet < DelegateClass(SubscriptionSet)
    WARN_POLICY        = Kernel.method(:warn)
    RAISE_ERROR_POLICY = ->(message) do
      fail UnknownEvent, message, caller.drop_while{|l| l.include?(__FILE__)}
    end

    attr_reader :known_types

    def initialize(subscription_set, options = {})
      super(subscription_set)
      @known_types = []
      @policy      = case policy = options.fetch(:policy) { :warn }
                     when :warn
                       WARN_POLICY
                     when :raise_error
                       RAISE_ERROR_POLICY
                     else
                       fail ArgumentError, "Invalid policy: #{policy}"
                     end
    end

    def on(event_name, &block)
      check_event_name(event_name)
      super
    end


    def emit(event_name, *)
      check_event_name(event_name)
      super
    end

    private

    def check_event_name(event_name)
      unless @known_types.include?(event_name)
        message =
            "##{__callee__} received for unknown event type '#{event_name}'"
        @policy.call(message)
      end
    end
  end
end
