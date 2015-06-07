module Brainguy
  # An event. Bundles up a symbolic `name`, an originating object (`source`).
  # and a list of event-defined `args`.
  Event = Struct.new(:name, :source, :args) do
    # @param name [Symbol] the event name
    # @param source [Object] the originating object
    # @param args [Array] a list of event-specific arguments
    def initialize(*)
      super
      self.args ||= []
    end
  end
end
