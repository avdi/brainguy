require "rspec"

require "brainguy"

describe "method-scoped subscription set" do
  class Kitten
    def play(&block)
      Brainguy.with_subscription_scope(self, block) do |events|
        events.emit(:mew)
        events.emit(:mew)
        events.emit(:pounce)
        events.emit(:hiss)
        events.emit(:purr)
      end
    end
  end

  it "executes handlers hooked up inside a passed block" do
    kitten = Kitten.new
    event_log = []
    kitten.play do |events|
      events.on(:hiss) do
        event_log << :hiss
      end
      events.on(:pounce) do
        event_log << :pounce
      end
      events.on(:mew) do
        event_log << :mew
      end
    end
    expect(event_log).to eq([:mew, :mew, :pounce, :hiss])
  end

  it "executes handlers chained onto the method return value" do
    kitten = Kitten.new
    event_log = []
    listener  = spy("listener")
    kitten.play.on(:purr) do
      event_log << :purr
    end.on(:pounce) do
      event_log << :pounce
    end.on(:mew) do
      event_log << :mew
    end.attach(listener)
    expect(event_log).to eq([:purr, :pounce, :mew, :mew])
    expect(listener).to have_received(:call).with(Brainguy::Event[:mew, kitten]).twice
    expect(listener).to have_received(:call).with(Brainguy::Event[:pounce, kitten])
    expect(listener).to have_received(:call).with(Brainguy::Event[:hiss, kitten])
    expect(listener).to have_received(:call).with(Brainguy::Event[:purr, kitten])
  end

  class Dog
    include Brainguy::Eventful

    def play_fetch
      emit(:chase_stick)
    end

    def play(&block)
      with_subscription_scope(block) do |events|
        emit(:bark)
        play_fetch
        emit(:pant)
      end
    end
  end

  it "can be used in conjunction with an Eventful object" do
    dog = Dog.new
    lifetime_listener = spy("lifetime listener")
    scoped_listener   = spy("scoped listener")
    dog.events.attach(lifetime_listener)
    dog.play do |events|
      events.attach(scoped_listener)
    end
    dog.play_fetch
    expect(lifetime_listener)
        .to have_received(:call).with(Brainguy::Event[:chase_stick, dog]).twice
    expect(scoped_listener)
        .to have_received(:call).with(Brainguy::Event[:chase_stick, dog]).once
  end
end
