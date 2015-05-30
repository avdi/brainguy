require "rspec"
require "brainguy/single_event_subscription"

module Brainguy
  RSpec.describe SingleEventSubscription do
    it "is not equal to another subscription with a different event" do
      owner = double("owner")
      listener = double("listener")
      sub1 = SingleEventSubscription.new(owner, listener, double)
      sub2 = SingleEventSubscription.new(owner, listener, double)
      expect(sub1).not_to eq(sub2)
      expect(sub1.hash).not_to eq(sub2.hash)
      expect(sub1).not_to eql(sub2)
    end
  end
end
