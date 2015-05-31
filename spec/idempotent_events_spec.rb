require "rspec"
require "brainguy"

module Brainguy
  class WebRequest
    attr_reader :events

    def initialize
      @events = Brainguy::IdempotentSubscriptionSet.new(self)
    end

    def successful_response
      events.emit(:data, "Hello, ")
      events.emit(:data, "World!")
      events.emit(:success)
    end
  end

  RSpec.describe "idempotent events" do
    it "replays events when a listener subscribes late" do
      r = WebRequest.new
      r.successful_response
      listener = spy("listener")
      r.events.attach(listener)
      expect(listener).to have_received(:call).with(r, :data, "Hello, ").ordered
      expect(listener).to have_received(:call).with(r, :data, "World!").ordered
      expect(listener).to have_received(:call).with(r, :success).ordered
    end

    it "replays events when a single-event handler subscribes late" do
      r = WebRequest.new
      r.successful_response
      expect do |b|
        r.events.on(:data, &b)
      end.to yield_successive_args([r, :data, "Hello, "],
                                   [r, :data, "World!"])
    end

    it "passes events on to existing listeners immediately" do
      r        = WebRequest.new
      listener = spy("listener")
      r.events.attach(listener)
      r.successful_response
      expect(listener).to have_received(:call).with(r, :data, "Hello, ").ordered
      expect(listener).to have_received(:call).with(r, :data, "World!").ordered
      expect(listener).to have_received(:call).with(r, :success).ordered
    end

    it "does not repeat events to preexisting listeners" do
      r        = WebRequest.new
      listener = spy("listener")
      r.events.attach(listener)
      r.successful_response
      r.events.attach(spy("new listener"))
      expect(listener).to have_received(:call).exactly(3).times
    end
  end
end