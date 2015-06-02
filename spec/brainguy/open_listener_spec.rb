require "rspec"
require "brainguy/open_listener"

module Brainguy
  RSpec.describe OpenListener do
    it "can be constructed from a hash" do
      probe = spy("probe")
      ol    = OpenListener.new(foo: ->(*a){ probe.handle_foo(*a) },
                               bar: ->(*a){ probe.handle_bar(*a) })
      source = double("source")
      ol.call(source, :foo, 1, 2)
      ol.call(source, :bar, 3, 4)
      expect(probe).to have_received(:handle_foo).with(source, :foo, 1, 2)
      expect(probe).to have_received(:handle_bar).with(source, :bar, 3, 4)
    end

    it "can be constructed using on_* methods" do
      probe = spy("probe")
      ol    = OpenListener.new
      ol.on_foo do |*args| probe.handle_foo(*args) end
        .on_bar do |*args| probe.handle_bar(*args) end
      source = double("source")
      ol.call(source, :foo, 1, 2)
      ol.call(source, :bar, 3, 4)
      expect(probe).to have_received(:handle_foo).with(source, :foo, 1, 2)
      expect(probe).to have_received(:handle_bar).with(source, :bar, 3, 4)
    end

    it "has correct #respond_to? behavior" do
      ol = OpenListener.new
      expect(ol).to respond_to(:on_blub)
      expect(ol).to_not respond_to(:blub)
    end
  end
end

