require "brainguy/version"
require "brainguy/event"
require "brainguy/subscription_set"
require "brainguy/idempotent_subscription_set"
require "brainguy/eventful"
require "brainguy/subscription_scope"
require "brainguy/fluent_subscription_set"

module Brainguy
  def self.with_subscription_scope(
      source, listener_block=nil, existing_subscription_set=nil)
    options = {}
    if existing_subscription_set
      options[:existing_subscriptions] = existing_subscription_set.subscriptions
    end
    subscriptions = IdempotentSubscriptionSet.new(source, options)
    subscriptions.with_subscription_scope do |scope|
      listener_block.call(scope) if listener_block
      yield scope
    end
    FluentSubscriptionSet.new(subscriptions)
  end
end
