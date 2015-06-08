require "brainguy"

events = Brainguy::Emitter.new
observer = proc do |event|
  puts "Got event: #{event.name}"
end
events.attach(observer)
events.emit(:ding)

# >> Got event: ding
