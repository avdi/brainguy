require "rspec"
require "brainguy/error_collecting_notifier"

module Brainguy
  RSpec.describe ErrorCollectingNotifier do
    it "collects errors into a list" do
      inner  = instance_spy(BasicNotifier, "inner")
      outer  = ErrorCollectingNotifier.new(inner)
      error1 = StandardError.new("Whoopsie")
      error2 = StandardError.new("O NOES")
      allow(inner).to receive(:notify).and_raise(error1)
      outer.notify(sub1 = double("subscription1"), double)
      allow(inner).to receive(:notify).and_raise(error2)
      outer.notify(sub2 = double("subscription2"), double)
      expect(outer.result)
          .to eq({sub1 => error1, sub2 => error2})
    end
  end
end
