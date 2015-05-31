require "rspec"
require "brainguy/eventful"

module Brainguy
  class CoffeeMaker
    include Brainguy::Eventful

    def make_coffee
      emit(:heat)
      emit(:drip)
      emit(:done)
    end
  end

  RSpec.describe Eventful do
    it "adds an #events attribute" do
      cm = CoffeeMaker.new
      cm.respond_to?(:events)
    end

    it "adds an #on method for attaching listeners" do
      cm = CoffeeMaker.new
      probe = spy
      cm.on(:done) do
        probe.coffee_done
      end
      cm.make_coffee
      expect(probe).to have_received(:coffee_done)
    end

    it "provides the #emit helper privately" do
      cm = CoffeeMaker.new
      expect{cm.emit(:foo)}.to raise_error(NoMethodError)
    end
  end
end
