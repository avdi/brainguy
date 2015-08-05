require "rspec"
require "brainguy/emitter"

module Brainguy
  RSpec.describe Emitter do
    it "uses notifier result for return value of #emit" do
      notifier = instance_double(BasicNotifier, result: "THE RESULT")
      e        = Emitter.new(double("event source"),
                             notifier_maker: ->() { notifier })
      expect(e.emit(:foo)).to eq("THE RESULT")
    end

    it "can set up multiple handlers at once with a hash of lambdas" do
      e      = Emitter.new(double)
      probe  = spy("probe")
      result = e.on(foo: proc { probe.handle_foo },
                    bar: proc { probe.handle_bar })
      expect(result.listener).to be_a(OpenObserver)
      e.emit(:foo)
      e.emit(:bar)
      expect(probe).to have_received(:handle_foo)
      expect(probe).to have_received(:handle_bar)
    end

    it "allows a client to subscribe to have a specific message sent" do
      e = Emitter.new(double)
      probe = spy("probe")
      e.on :shazam, send: :abracadabra, to: probe
      e.emit(:shazam)
      expect(probe).to have_received(:abracadabra)
    end

    it "allows callback subscriptions to include arguments" do
      e = Emitter.new(double)
      probe = spy("probe")
      e.on :shazam, send: [:abracadabra, {x: 3, y: 5}], to: probe
      e.emit(:shazam)
      expect(probe).to have_received(:abracadabra).with(x: 3, y: 5)
    end

    it "allows callback subscriptions to include arguments using a keyword" do
      e = Emitter.new(double)
      probe = spy("probe")
      e.on :shazam, send: :abracadabra, to: probe, with: [{x: 3, y: 5}]
      e.emit(:shazam)
      expect(probe).to have_received(:abracadabra).with(x: 3, y: 5)
    end
  end
end
