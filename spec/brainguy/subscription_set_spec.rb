require "rspec"
require "brainguy/subscription_set"

module Brainguy
  RSpec.describe SubscriptionSet do
    it "uses notifier result for return value of #emit" do
      notifier = instance_double(BasicNotifier, result: "THE RESULT")
      ss       = SubscriptionSet.new(double("event source"),
                                     notifier_maker: ->() { notifier })
      expect(ss.emit(:foo)).to eq("THE RESULT")
    end

    it "can set up multiple handlers at once with a hash of lambdas" do
      ss     = SubscriptionSet.new(double)
      probe  = spy("probe")
      result = ss.on(foo: -> (*){ probe.handle_foo },
                     bar: -> (*){ probe.handle_bar })
      expect(result.listener).to be_a(OpenListener)
      ss.emit(:foo)
      ss.emit(:bar)
      expect(probe).to have_received(:handle_foo)
      expect(probe).to have_received(:handle_bar)
    end
  end
end
