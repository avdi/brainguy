require "brainguy"

class Poem
  include Brainguy::Observable
  def recite(&block)
    with_subscription_scope(block) do
      emit(:title, "Jabberwocky")
      emit(:line, "'twas brillig, and the slithy toves")
      emit(:line, "Did gyre and gimbal in the wabe")
    end
  end
end

class HtmlFormatter
  include Brainguy::Observer

  attr_reader :result
  
  def initialize
    @result = ""
  end
  
  def on_title(event)
    @result << "<h1>#{event.args.first}</h1>"
  end

  def on_line(event)
    @result << "#{event.args.first}</br>"
  end
end

p = Poem.new
f = HtmlFormatter.new
p.recite do |events|
  events.attach(f)
end

f.result
# => "<h1>Jabberwocky</h1>'twas brillig, and the slithy toves</br>Did gyre an...
