require "brainguy/error_handling_notifier"

module Brainguy
  # A notifier wrapper that captures exceptions and collects them into a Hash.
  class ErrorCollectingNotifier < ErrorHandlingNotifier
    # (see ErrorHandlingNotifier#initialize)
    def initialize(notifier)
      super(notifier, method(:add_error))
      @errors = {}
    end

    # Add another error to the list
    # @api private
    def add_error(subscription, error)
      @errors[subscription] = error
    end

    # Return list of errors captured while notifying subscriptions. One entry
    # for every subscription that raised an error.
    #
    # @return [Hash{Subscription => Exception}]
    def result
      @errors
    end
  end
end
