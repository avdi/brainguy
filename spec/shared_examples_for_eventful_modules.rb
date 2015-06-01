module Brainguy
  RSpec.shared_examples "an eventful module" do |the_module|
    let(:coffee_maker_class) {
      Class.new do

        include the_module

        def make_coffee
          emit(:heat)
          emit(:drip)
          emit(:done)
        end
      end
    }

    it "adds an #events attribute" do
      cm = coffee_maker_class.new
      cm.respond_to?(:events)
    end

    it "adds an #on method for attaching listeners" do
      cm    = coffee_maker_class.new
      probe = spy
      cm.on(:done) do
        probe.coffee_done
      end
      cm.make_coffee
      expect(probe).to have_received(:coffee_done)
    end

    it "provides the #emit helper privately" do
      cm = coffee_maker_class.new
      expect { cm.emit(:foo) }.to raise_error(NoMethodError)
    end
  end
end
