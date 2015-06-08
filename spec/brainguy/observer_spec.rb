require "rspec"
require "brainguy/observer"

module Brainguy
  RSpec.describe Observer do
    class AccountListener
      def on_open(event)
      end

      include Observer

      def on_deposit(event)
      end

      def on_withdrawal(event)
      end
    end

    it "routes events to their appropriate handler methods" do
      listener = AccountListener.new
      allow(listener).to receive(:on_deposit)
      allow(listener).to receive(:on_withdrawal)

      listener.call(e1 = Event[:deposit])
      expect(listener).to have_received(:on_deposit).with(e1)

      listener.call(e2 = Event[:withdrawal])
      expect(listener).to have_received(:on_withdrawal).with(e2)
    end

    it "picks up handler methods defined before module inclusion" do
      klass    = Class.new do
        def on_open(event)

        end

        include Observer
      end
      listener = klass.new
      allow(listener).to receive(:on_open)
      listener.call(e2 = Event[:open])
      expect(listener).to have_received(:on_open).with(e2)
    end

    it "ignores events which lack handler methods" do
      listener = AccountListener.new
      expect { listener.call(Event[:not_defined]) }.to_not raise_error
    end

    it "doesn't blow up on a handler-less class" do
      expect do
        Class.new do
          include Observer
        end
      end.to_not raise_error
    end

    it "passes unknown events to a catch-all method" do
      events = []
      klass = Class.new do
        include Observer
        define_method :event_handler_missing do |event|
          events << event
        end
      end
      listener = klass.new
      listener.call(unknown_event = Event[:unknown_event])
      expect(events).to eq([unknown_event])
    end

  end
end
