require "brainguy"

events = Brainguy::Emitter.new
listener = proc do |event|
  puts "Got event: #{event.name}"
end
events.attach(listener)
events.emit(:ding)

# >> Got event: ding
