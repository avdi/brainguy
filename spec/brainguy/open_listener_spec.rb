require "rspec"
require "brainguy/open_listener"

module Brainguy
  RSpec.describe OpenListener do
    it "can be constructed from a hash" do
      probe  = spy("probe")
      ol     = OpenListener.new(foo: ->(e) { probe.handle_foo(e) },
                                bar: ->(e) { probe.handle_bar(e) })
      source = double("source")
      ol.call(e1 = Event[:foo])
      ol.call(e2 = Event[:bar])
      expect(probe).to have_received(:handle_foo).with(e1)
      expect(probe).to have_received(:handle_bar).with(e2)
    end

    it "can be constructed using on_* methods" do
      probe = spy("probe")
      ol    = OpenListener.new
      ol.on_foo do |e|
        probe.handle_foo(e)
      end
          .on_bar do |e|
        probe.handle_bar(e)
      end
      source = double("source")
      ol.call(e1 = Event[:foo])
      ol.call(e2 = Event[:bar])
      expect(probe).to have_received(:handle_foo).with(e1)
      expect(probe).to have_received(:handle_bar).with(e2)
    end

    it "yields self on init" do
      probe  = spy("probe")
      ol     = OpenListener.new do |l|
        l.on_foo do |e|
          probe.handle_foo(e)
        end
        l.on_bar do |e|
          probe.handle_bar(e)
        end
      end
      source = double("source")
      ol.call(e1 = Event[:foo])
      ol.call(e2 = Event[:bar])
      expect(probe).to have_received(:handle_foo).with(e1)
      expect(probe).to have_received(:handle_bar).with(e2)
    end

    it "has correct #respond_to? behavior" do
      ol = OpenListener.new
      expect(ol).to respond_to(:on_blub)
      expect(ol).to_not respond_to(:blub)
    end
  end
end

