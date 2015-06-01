require "rspec"
require "brainguy/manifestly_eventful"
require "shared_examples_for_eventful_modules"

module Brainguy
  RSpec.describe ManifestlyEventful do
    include_examples "an eventful module",
                     ManifestlyEventful.new(:heat, :drip, :done)

    it "adds a ManifestSubscriptionSet to the class" do
      klass = Class.new do
        include ManifestlyEventful.new(:red, :green)
      end
      obj = klass.new
      expect(obj.events).to be_a(ManifestSubscriptionSet)
    end

    it "adds the specified event names to the known list" do
      klass = Class.new do
        include ManifestlyEventful.new(:red, :green)
      end
      obj = klass.new
      expect(obj.events.known_types).to eq([:red, :green])
    end
  end
end
