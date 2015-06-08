require "brainguy"

class Toaster
  include Brainguy::Observable

  def make_toast
    emit(:start)
    emit(:pop)
  end
end

toaster = Toaster.new
toaster.on(:pop) do
  puts "Toast is done!"
end
toaster.make_toast

# >> Toast is done!
