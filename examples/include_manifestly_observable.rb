require "brainguy"

class Toaster
  include Brainguy::ManifestlyObservable.new(:start, :pop)

  def make_toast
    emit(:start)
    emit(:lop)
  end
end

toaster = Toaster.new
toaster.events.unknown_event_policy = :raise_error
toaster.on(:plop) do
  puts "Toast is done!"
end
toaster.make_toast

# ~> Brainguy::UnknownEvent
# ~> #on received for unknown event type 'plop'
# ~>
# ~> xmptmp-in27856uxq.rb:14:in `<main>'
