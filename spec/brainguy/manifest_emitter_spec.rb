require "rspec"
require "brainguy/manifest_emitter"

module Brainguy
  RSpec.describe ManifestEmitter do
    it "starts with an empty set of known events" do
      set = ManifestEmitter.new(instance_double(Emitter))
      expect(set.known_types).to be_empty
    end

    it "warns when a handler is added for an unknown event" do
      set = ManifestEmitter.new(
          instance_double(Emitter, on: nil))
      expect { set.on(:foo) {} }
          .to output(/unknown event type 'foo'/i).to_stderr
    end

    it "warns when an unknown event is emitted" do
      set = ManifestEmitter.new(
          instance_double(Emitter, emit: nil))
      expect { set.emit(:foo) {} }
          .to output(/unknown event type 'foo'/i).to_stderr
    end

    it "does not warn when a handler is added for an known event" do
      set = ManifestEmitter.new(
          instance_double(Emitter, on: nil))
      set.known_types << :foo
      expect { set.on(:foo) {} }
          .not_to output.to_stderr
    end

    it "does not warn when an known event is emitted" do
      set = ManifestEmitter.new(
          instance_double(Emitter, emit: nil))
      set.known_types << :foo
      expect { set.emit(:foo) {} }
          .not_to output.to_stderr
    end

    context "configured to raise errors" do
      it "fails when a handler is added for an unknown event" do
        set = ManifestEmitter.new(
            instance_double(Emitter, on: nil),
            policy: :raise_error)
        expect { set.on(:foo) {} }
            .to raise_error(UnknownEvent, /unknown event type 'foo'/i)
      end

      it "fails when an unknown event is emitted" do
        set = ManifestEmitter.new(
            instance_double(Emitter, emit: nil),
            policy: :raise_error)
        expect { set.emit(:foo) {} }
            .to raise_error(UnknownEvent, /unknown event type 'foo'/i)
      end

      it "reports exception from the send point" do
        set = ManifestEmitter.new(
            instance_double(Emitter, emit: nil),
            policy: :raise_error)
        error = set.emit(:foo) rescue $!; line = __LINE__
        file  = File.basename(__FILE__)
        expect(error.backtrace[0]).to include("#{file}:#{line}")
      end
    end
  end
end
