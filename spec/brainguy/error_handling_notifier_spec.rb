require "rspec"
require "brainguy/error_handling_notifier"

module Brainguy
  RSpec.describe ErrorHandlingNotifier do
    it "passes notifications through" do
      inner = instance_spy(BasicNotifier, "inner")
      outer = ErrorHandlingNotifier.new(inner)
      outer.notify(double, double)
      expect(inner).to have_received(:notify)
    end

    it "enables exceptions to be handled by an arbitrary callable" do
      handler = double("handler", :call => nil)
      inner = instance_spy(BasicNotifier, "inner")
      outer = ErrorHandlingNotifier.new(inner, handler)
      error = StandardError.new("Whoopsie")
      allow(inner).to receive(:notify).and_raise(error)
      outer.notify(sub = double("subscription"), double)
      expect(handler).to have_received(:call).with(sub, error)
    end

    it "re-raises errors if no handler is supplied" do
      inner = instance_spy(BasicNotifier, "inner")
      outer = ErrorHandlingNotifier.new(inner)
      error = StandardError.new("Whoopsie")
      allow(inner).to receive(:notify).and_raise(error)
      expect{outer.notify(double, double)}.to raise_error(error)
    end

    it "provides a mnemonic for the default re-raise behavior" do
      inner = instance_spy(BasicNotifier, "inner")
      outer = ErrorHandlingNotifier.new(inner, :raise)
      error = StandardError.new("Whoopsie")
      allow(inner).to receive(:notify).and_raise(error)
      expect{outer.notify(double, double)}.to raise_error(error)
    end

    it "provides a mnemonic for suppressing errors" do
      inner = instance_spy(BasicNotifier, "inner")
      outer = ErrorHandlingNotifier.new(inner, :suppress)
      error = StandardError.new("Whoopsie")
      allow(inner).to receive(:notify).and_raise(error)
      expect{outer.notify(double, double)}.to_not raise_error
    end

    it "provides a mnemonic for converting errors to warnings" do
      inner = instance_spy(BasicNotifier, "inner")
      outer = ErrorHandlingNotifier.new(inner, :warn)
      error = StandardError.new("Whoopsie")
      allow(inner).to receive(:notify).and_raise(error)
      expect{outer.notify(double, double)}
          .to output(/StandardError: Whoopsie/).to_stderr
    end

    it "has a result of nil" do
      inner = instance_spy(BasicNotifier, "inner")
      outer = ErrorHandlingNotifier.new(inner)
      outer.notify(double, double)
      expect(outer.result).to be_nil
    end
  end
end
