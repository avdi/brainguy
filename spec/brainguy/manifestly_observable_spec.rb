require "rspec"
require "brainguy/manifestly_observable"
require "support/shared_examples_for_eventful_modules"

module Brainguy
  RSpec.describe ManifestlyObservable do
    include_examples "an eventful module",
                     ManifestlyObservable.new(:heat, :drip, :done)

    it "adds a ManifestEmitter to the class" do
      klass = Class.new do
        include ManifestlyObservable.new(:red, :green)
      end
      obj   = klass.new
      expect(obj.events).to be_a(ManifestEmitter)
    end

    it "adds the specified event names to the known list" do
      klass = Class.new do
        include ManifestlyObservable.new(:red, :green)
      end
      obj   = klass.new
      expect(obj.events.known_types).to eq([:red, :green])
    end

    it "inherits event names" do
      parent = Class.new do
        include ManifestlyObservable.new(:red, :green)
      end
      child  = Class.new(parent) do
        include ManifestlyObservable.new(:yellow)
      end
      obj    = child.new
      expect(obj.events.known_types).to eq([:red, :green, :yellow])
    end

    it "stringifies meaningfully" do
      mod = ManifestlyObservable.new(:red, :green)
      expect(mod.to_s).to eq("ManifestlyObservable(:red, :green)")
    end

  end
end
