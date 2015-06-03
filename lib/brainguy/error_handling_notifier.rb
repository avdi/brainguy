require "brainguy/basic_notifier"

module Brainguy
  class ErrorHandlingNotifier < DelegateClass(BasicNotifier)
    SUPPRESS_STRATEGY = ->(_subscription, _error) do
      # NOOP
    end
    WARN_STRATEGY = ->(_subscription, error) do
      warn "#{error.class}: #{error.message}"
    end
    RAISE_STRATEGY = ->(_subscription, error) do
      raise error
    end

    def initialize(notifier, error_handler = RAISE_STRATEGY)
      super(notifier)
      @error_handler = resolve_error_handler(error_handler)
    end

    def notify(subscription, *)
      super
    rescue => error
      @error_handler.call(subscription, error)
    end

    def result
      nil
    end

    private

    def resolve_error_handler(handler)
      case handler
      when :suppress then SUPPRESS_STRATEGY
      when :warn     then WARN_STRATEGY
      when :raise    then RAISE_STRATEGY
      when Symbol    then fail ArgumentError, "Unknown mnemonic: #{handler}"
      else handler
      end
    end
  end
end
