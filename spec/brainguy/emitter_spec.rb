require "rspec"
require "brainguy/emitter"

module Brainguy
  RSpec.describe Emitter do
    it "uses notifier result for return value of #emit" do
      notifier = instance_double(BasicNotifier, result: "THE RESULT")
      ss       = Emitter.new(double("event source"),
                                     notifier_maker: ->() { notifier })
      expect(ss.emit(:foo)).to eq("THE RESULT")
    end

    it "can set up multiple handlers at once with a hash of lambdas" do
      ss     = Emitter.new(double)
      probe  = spy("probe")
      result = ss.on(foo: proc { probe.handle_foo },
                     bar: proc { probe.handle_bar })
      expect(result.listener).to be_a(OpenObserver)
      ss.emit(:foo)
      ss.emit(:bar)
      expect(probe).to have_received(:handle_foo)
      expect(probe).to have_received(:handle_bar)
    end
  end
end
