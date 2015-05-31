require "rspec"
require "brainguy/subscription_set"

module Brainguy
  RSpec.describe SubscriptionSet do
    it "uses notifier result for return value of #emit" do
      notifier = instance_double(BasicNotifier, result: "THE RESULT")
      ss = SubscriptionSet.new(double("event source"),
                               notifier_maker: ->() { notifier })
      expect(ss.emit(:foo)).to eq("THE RESULT")
    end
  end
end
