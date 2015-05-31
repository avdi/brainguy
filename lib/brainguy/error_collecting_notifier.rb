require "brainguy/error_handling_notifier"

module Brainguy
  class ErrorCollectingNotifier < ErrorHandlingNotifier
    def initialize(notifier)
      super(notifier, method(:add_error))
      @errors = {}
    end

    def add_error(subscription, error)
      @errors[subscription] = error
    end

    def result
      @errors
    end
  end
end
