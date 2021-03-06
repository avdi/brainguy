require "brainguy/emitter"
require "delegate"

module Brainguy
  # Raised for an event that is not listed in the manifest.
  class UnknownEvent < StandardError
  end

  # A {Emitter} wrapper which "locks down" a subscription set to a
  # known list of event names. Useful for preventing typos in event names.
  class ManifestEmitter < DelegateClass(Emitter)

    # A policy which outputs a warning on unrecognized event names
    WARN_POLICY        = Kernel.method(:warn)

    # A policy which raises an exception on unrecognized evend names.
    RAISE_ERROR_POLICY = ->(message) do
      fail UnknownEvent, message, caller.drop_while{|l| l.include?(__FILE__)}
    end

    # The list of known event names
    # @return [Array<Symbol>]
    attr_reader :known_types

    # @param subscription_set [Emitter] the set to be wrapped
    # @param options [Hash] a hash of options
    # @option options [:call, Symbol] :policy the policy for what to do on
    #   unknown event names. A callable or a mnemonic symbol.
    #   The following mnemonics are supported:
    #
    #     - `:warn`: Output a warning
    #     - `:raise_error`: Raise an exception
    def initialize(subscription_set, options = {})
      super(subscription_set)
      @known_types = []
      policy = options.fetch(:policy) { :warn }
      @policy      = resolve_policy(policy)
    end


    def unknown_event_policy=(new_policy)
      @policy = resolve_policy(new_policy)
    end

    # (see Emitter#on)
    def on(event_name, &block)
      check_event_name(event_name, __callee__)
      super
    end

    # (see Emitter#emit)
    def emit(event_name, *)
      check_event_name(event_name, __callee__)
      super
    end

    private

    def check_event_name(event_name, method_name)
      unless @known_types.include?(event_name)
        message =
            "##{method_name} received for unknown event type '#{event_name}'"
        @policy.call(message)
      end
    end

    def resolve_policy(policy)
      case policy
      when :warn
        WARN_POLICY
      when :raise_error
        RAISE_ERROR_POLICY
      else
        fail ArgumentError, "Invalid policy: #{policy}"
      end
    end
  end
end
