require "rspec"
require "brainguy/subscription"

module Brainguy
  RSpec.describe Subscription do

    it "is equal to another subscription with the same owner and listener" do
      listener = double("listener")
      owner    = double("owner")
      sub1     = Subscription.new(owner, listener)
      sub2     = Subscription.new(owner, listener)
      expect(sub1).to eq(sub2)
      expect(sub1.hash).to eq(sub2.hash)
      expect(sub1).to eql(sub2)

      set = Set.new([sub1])
      expect(set.add?(sub2)).to be_nil
      expect(set.size).to eq(1)
      set.delete(sub2)
      expect(set.size).to eq(0)
    end

    it "is not equal to another subscription with a different owner" do
      listener = double("listener")
      sub1     = Subscription.new(double, listener)
      sub2     = Subscription.new(double, listener)
      expect(sub1).not_to eq(sub2)
      expect(sub1.hash).not_to eq(sub2.hash)
      expect(sub1).not_to eql(sub2)
    end

    it "is not equal to another subscription with a different listener" do
      owner = double("owner")
      sub1  = Subscription.new(owner, double)
      sub2  = Subscription.new(owner, double)
      expect(sub1).not_to eq(sub2)
      expect(sub1.hash).not_to eq(sub2.hash)
      expect(sub1).not_to eql(sub2)
    end

    it "is frozen" do
      s = Subscription.new(double, double)
      expect(s).to be_frozen
    end
  end
end
