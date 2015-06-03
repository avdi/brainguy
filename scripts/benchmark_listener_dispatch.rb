require "benchmark/ips"

Event = Struct.new(:name, :source, :args)

class TestBed
  attr_reader :event_log

  def initialize
    @event_log = []
  end
end

class HardcodeTestbed < TestBed
  def call(event)
    case event.name
    when :foo
      handle_foo(event)
    when :bar
      handle_bar(event)
    when :baz
      handle_baz(event)
    end
  end

  def handle_foo(event)
    event_log << event
  end

  def handle_bar(event)
    event_log << event
  end

  def handle_baz(event)
    event_log << event
  end
end

class SendTestbed < TestBed
  def call(event)
    handler_name = "handle_#{event.name}"
    __send__(handler_name, event) if respond_to?(handler_name)
  end

  def handle_foo(event)
    event_log << event
  end

  def handle_bar(event)
    event_log << event
  end

  def handle_baz(event)
    event_log << event
  end
end

class SendTableTestbed < TestBed
  def self.method_added(method_name)
    if method_name.to_s =~ /\Ahandle_(.+)\z/
      handler_methods[$1.to_sym] = method_name.to_sym
    end
    super
  end

  def self.handler_methods
    @handler_methods ||= {}
  end

  def call(event)
    if (handler_method = self.class.handler_methods[event.name])
      __send__(handler_method, event)
    end
  end

  def handle_foo(event)
    event_log << event
  end

  def handle_bar(event)
    event_log << event
  end

  def handle_baz(event)
    event_log << event
  end
end

class BindTableTestbed < TestBed
  def self.method_added(method_name)
    if method_name.to_s =~ /\Ahandle_(.+)\z/
      handler_methods[$1.to_sym] = instance_method(method_name)
    end
    super
  end

  def self.handler_methods
    @handler_methods ||= {}
  end

  def call(event)
    if (handler_method = self.class.handler_methods[event.name])
      handler_method.bind(self).call(event)
    end
  end

  def handle_foo(event)
    event_log << event
  end

  def handle_bar(event)
    event_log << event
  end

  def handle_baz(event)
    event_log << event
  end
end

class CodeGenTestbed < TestBed
  def self.method_added(method_name)
    if method_name.to_s =~ /\Ahandle_(.+)\z/
      handler_methods << $1
      regenerate_dispatch_method
    end
    super
  end

  def self.handler_methods
    @handler_methods ||= []
  end

  def self.regenerate_dispatch_method
    dispatch_table = handler_methods.map { |event_name|
      "when :#{event_name} then handle_#{event_name}(event)"
    }.join("\n")
    class_eval %{
      def call(event)
        case event.name
        #{dispatch_table}
        end
      end
    }
  end

  def handle_foo(event)
    event_log << event
  end

  def handle_bar(event)
    event_log << event
  end

  def handle_baz(event)
    event_log << event
  end
end

class IfCodeGenTestbed < TestBed
  def self.method_added(method_name)
    if method_name.to_s =~ /\Ahandle_(.+)\z/
      handler_methods << $1
      regenerate_dispatch_method
    end
    super
  end

  def self.handler_methods
    @handler_methods ||= []
  end

  def self.regenerate_dispatch_method
    dispatch_table = handler_methods.map { |event_name|
      "event.name.equal?(:#{event_name}) then handle_#{event_name}(event)"
    }.join("\nelsif ")
    class_eval %{
      def call(event)
        if #{dispatch_table}
        end
      end
    }
  end

  def handle_foo(event)
    event_log << event
  end

  def handle_bar(event)
    event_log << event
  end

  def handle_baz(event)
    event_log << event
  end
end

def do_test(klass)
  testbed = klass.new
  testbed.call(e1 = Event[:foo])
  testbed.call(e2 = Event[:bar])
  testbed.call(e3 = Event[:baz])
  testbed.call(Event[:buz])
  unless testbed.event_log == [e1, e2, e3]
    fail "#{klass}: #{testbed.event_log.inspect}"
  end
end

classes = [
    HardcodeTestbed,
    SendTestbed,
    SendTableTestbed,
    BindTableTestbed,
    CodeGenTestbed,
    IfCodeGenTestbed,
]
width   = classes.map(&:name).map(&:size).max

Benchmark.ips do |x|
  classes.each do |klass|
    x.report(klass.name) { do_test(klass) }
  end
  x.compare!
end
