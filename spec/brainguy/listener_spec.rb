require "rspec"
require "brainguy/listener"

module Brainguy
  RSpec.describe Listener do
    class AccountListener
      def on_open(event)
      end

      include Listener

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
      klass = Class.new do
        def on_open(event)

        end
        include Listener
      end
      listener = klass.new
      allow(listener).to receive(:on_open)
      listener.call(e2 = Event[:open])
      expect(listener).to have_received(:on_open).with(e2)
    end

    it "ignores events which lack handler methods" do
      listener = AccountListener.new
      expect{ listener.call(Event[:not_defined]) }.to_not raise_error
    end

  end
end
