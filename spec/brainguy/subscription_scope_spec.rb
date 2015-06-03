require "rspec"
require "brainguy/subscription_scope"

module Brainguy
  RSpec.describe SubscriptionScope do
    it "proxies subscriptions to an underlying subscription set" do
      scope = SubscriptionScope.new(set = instance_double(SubscriptionSet))
      allow(set).to receive(:on).and_return(sub1 = double("sub1"))
      allow(set).to receive(:attach).and_return(sub2 = double("sub2"))
      expect(scope.on(:foo)).to be(sub1)
      expect(scope.attach(arg2 = double)).to be(sub2)
      expect(set).to have_received(:on).with(:foo)
      expect(set).to have_received(:attach).with(arg2)
    end

    it "removes subscriptions on close" do
      scope = SubscriptionScope.new(set = instance_double(SubscriptionSet))
      allow(set).to receive(:on)
                        .and_return(sub1 = instance_spy(Subscription))
      allow(set).to receive(:attach)
                        .and_return(sub2 = instance_spy(Subscription))
      scope.on(:foo)
      scope.attach(double)
      scope.close
      expect(sub1).to have_received(:cancel)
      expect(sub2).to have_received(:cancel)
    end

    it "removes subscriptions only once" do
      scope = SubscriptionScope.new(set = instance_double(SubscriptionSet))
      allow(set).to receive(:on)
                        .and_return(sub1 = instance_spy(Subscription))
      scope.on(:foo)
      scope.close
      scope.close
      expect(sub1).to have_received(:cancel).once
    end

    it "supports a block form" do
      set = instance_double(SubscriptionSet)
      allow(set).to receive(:on)
                        .and_return(sub1 = instance_spy(Subscription))
      allow(set).to receive(:attach)
                        .and_return(sub2 = instance_spy(Subscription))

      SubscriptionScope.open(set) do |scope|
        scope.on(:foo)
        scope.attach(double)
      end

      expect(sub1).to have_received(:cancel)
      expect(sub2).to have_received(:cancel)
    end

    it "ensures subscriptions are cancelled despite errors in block" do
      set = instance_double(SubscriptionSet)
      allow(set).to receive(:on)
                        .and_return(sub1 = instance_spy(Subscription))
      allow(set).to receive(:attach)
                        .and_return(sub2 = instance_spy(Subscription))

      SubscriptionScope.open(set) do |scope|
        scope.on(:foo)
        scope.attach(double)
        fail "Whoopsie"
      end rescue nil

      expect(sub1).to have_received(:cancel)
      expect(sub2).to have_received(:cancel)
    end
  end
end
