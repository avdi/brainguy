module Brainguy
  Event = Struct.new(:name, :source, :args) do
    def initialize(*)
      super
      self.args ||= []
    end
  end
end
