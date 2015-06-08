require "brainguy"

class VideoRender
  include Brainguy::Observable
  attr_reader :name
  def initialize(name)
    @name = name
  end
  
  def do_render
    emit(:complete)
  end
end

v1 = VideoRender.new("foo.mp4")
v2 = VideoRender.new("bar.mp4")

observer = Brainguy::OpenObserver.new do |o|
  o.on_complete do |event|
    puts "Video #{event.source.name} is done rendering!"
  end
end

v1.events.attach(observer)
v2.events.attach(observer)

v1.do_render
v2.do_render

# >> Video foo.mp4 is done rendering!
# >> Video bar.mp4 is done rendering!
