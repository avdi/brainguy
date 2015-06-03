require "rspec"
require "brainguy/listener"

module Brainguy
  RSpec.describe Listener do
    class AccountListener
      def handle_open(event)
      end

      include Listener

      def handle_deposit(event)
      end

      def handle_withdrawal(event)
      end
    end

    it "routes events to their appropriate handler methods" do
      listener = AccountListener.new
      allow(listener).to receive(:handle_deposit)
      allow(listener).to receive(:handle_withdrawal)

      listener.call(e1 = Event[:deposit])
      expect(listener).to have_received(:handle_deposit).with(e1)

      listener.call(e2 = Event[:withdrawal])
      expect(listener).to have_received(:handle_withdrawal).with(e2)
    end

    it "picks up handler methods defined before module inclusion" do
      klass = Class.new do
        def handle_open(event)

        end
        include Listener
      end
      listener = klass.new
      allow(listener).to receive(:handle_open)
      listener.call(e2 = Event[:open])
      expect(listener).to have_received(:handle_open).with(e2)
    end

    it "ignores events which lack handler methods" do
      listener = AccountListener.new
      expect{ listener.call(Event[:not_defined]) }.to_not raise_error
    end

  end
end
