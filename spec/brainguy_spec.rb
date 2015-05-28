require "rspec"

class SatelliteOfLove
  Event = Struct.new(:name)

  def initialize
    add_event_type(:movie_sign)
    add_event_type(:power_out)
  end

  def events
    @events.keys.map{|name| Event.new(name) }
  end

  def on(event_name, &block)
    @events[event_name] << block
  end

  def send_the_movie
    emit(:movie_sign)
  end

  def send_final_sacrifice
    emit(:movie_sign, origin: "Canada", hero: "Zap Rowsdower")
  end

  def disconnect
    emit(:power_out)
  end

  def emit(event_name, *extra_args)
    @events[event_name].each do |handler|
      handler.call(self, event_name, *extra_args)
    end
  end

  def add_event_type(event_name)
    @events ||= {}
    @events[event_name] ||= []
  end
end

RSpec.describe Brainguy do
  it "enables objects to publish simple events" do
    mike = spy("mike")
    sol  = SatelliteOfLove.new
    sol.on(:movie_sign) do
      mike.panic!
    end
    sol.send_the_movie
    expect(mike).to have_received(:panic!)
  end

  it "allows multiple listeners to subscribe" do
    mike = spy("mike")
    crow = spy("crow")
    sol  = SatelliteOfLove.new
    sol.on(:movie_sign) do
      mike.panic!
    end
    sol.on(:movie_sign) do
      crow.also_panic!
    end
    sol.send_the_movie
    expect(mike).to have_received(:panic!)
    expect(crow).to have_received(:also_panic!)
  end

  it "allows multiple events to be emitted" do
    crow = spy("crow")
    sol  = SatelliteOfLove.new
    sol.on(:movie_sign) do
      crow.panic
    end
    sol.on(:power_out) do
      crow.loot
    end
    sol.send_the_movie
    expect(crow).to have_received(:panic)
    expect(crow).to_not have_received(:loot)
    sol.disconnect
    expect(crow).to have_received(:loot)
  end

  it "allows for zero subscribers" do
    sol = SatelliteOfLove.new
    expect { sol.send_the_movie }.to_not raise_error
  end

  it "passes the event emitting object to handler blocks" do
    sol = SatelliteOfLove.new
    expect do |b|
      sol.on(:movie_sign, &b)
      sol.send_the_movie
    end.to yield_with_args(sol, anything)
    expect do |b|
      sol.on(:power_out, &b)
      sol.disconnect
    end.to yield_with_args(sol, anything)
  end

  it "passes the event name to handler blocks" do
    sol = SatelliteOfLove.new
    expect do |b|
      sol.on(:movie_sign, &b)
      sol.send_the_movie
    end.to yield_with_args(anything, :movie_sign)
  end

  it "passes extra args on to the handler block" do
    sol = SatelliteOfLove.new
    movie_info = :not_set
    sol.on(:movie_sign) do |object, event, info|
      movie_info = info
    end
    sol.send_final_sacrifice
    expect(movie_info[:origin]).to eq("Canada")
    expect(movie_info[:hero]).to eq("Zap Rowsdower")
  end

  it "can list events" do
    sol = SatelliteOfLove.new
    event_names = sol.events.map(&:name).sort
    expect(event_names).to eq([:movie_sign, :power_out])
  end
end
