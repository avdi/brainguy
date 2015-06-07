require "brainguy/basic_notifier"

module Brainguy
  # It is possible that errors may be raised when notifying listeners. This
  # notifier wrapper class provides some leeway in how to handle those
  # errors. It does this by capturing errors and applying a policy to them.
  #
  # Includes a selection of common error policies.
  class ErrorHandlingNotifier < DelegateClass(BasicNotifier)
    # The suppression strategy. Throws errors away.
    SUPPRESS_STRATEGY = ->(_subscription, _error) do
      # NOOP
    end

    # The warning strategy. Turns errors into warnings.
    WARN_STRATEGY = ->(_subscription, error) do
      warn "#{error.class}: #{error.message}"
    end

    # The raise strategy. Re-raises errors as if they had never been captured.
    RAISE_STRATEGY = ->(_subscription, error) do
      raise error
    end

    # @param notifier [#notify] the notifier to wrap
    # @param error_handler [:call] a callable that determined error policy
    #   There are some symbolic shortcuts available here:
    #   - `:suppress`: Suppress errors completely.
    #   - `:warn`: Convert errors to warnings.
    #   - `:raise`: Re-raise errors.
    def initialize(notifier, error_handler = RAISE_STRATEGY)
      super(notifier)
      @error_handler = resolve_error_handler(error_handler)
    end

    # Notify a `subscription` of an event, and apply the error policy to any
    # exception that is raised.
    #
    # @return [@Object] whatever the underlying notifier returned
    def notify(subscription, *)
      super
    rescue => error
      @error_handler.call(subscription, error)
    end

    # @return [nil]
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
