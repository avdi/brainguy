require "brainguy/version"
require "brainguy/event"
require "brainguy/emitter"
require "brainguy/idempotent_subscription_set"
require "brainguy/eventful"
require "brainguy/subscription_scope"
require "brainguy/fluent_emitter"
require "brainguy/listener"

# Namespace for the `brainguy` gem. See {file:README.md} for usage instructions.
module Brainguy
  # Execute passed block with a temporary subscription scope. See README for
  # examples.
  #
  # @param source   the object initiating the event
  # @param listener_block [:call] an optional callable that should hook up
  #   listeners
  # @param subscription_set [Emitter] an existing subscription set to
  #   layer on top of
  def self.with_subscription_scope(
      source,
      listener_block   = nil,
      subscription_set = IdempotentSubscriptionSet.new(source))
    subscription_set.with_subscription_scope do |scope|
      listener_block.call(scope) if listener_block
      yield scope
    end
    unless listener_block
      FluentEmitter.new(subscription_set)
    end
  end
end
