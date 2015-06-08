require "brainguy"

class Toaster
  attr_reader :events

  def initialize
    @events = Brainguy::Emitter.new(self)
  end

  def make_toast
    events.emit(:start)
    events.emit(:pop)
  end
end

toaster = Toaster.new
toaster.events.on(:pop) do
  puts "Toanst is done!"
end
toaster.make_toast

# >> Toast is done!
