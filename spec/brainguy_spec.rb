require "rspec"

class SatelliteOfLove
  def initialize
    @handlers = Hash.new do |h, k|
      h[k] = []
    end
  end

  def on(event_name, &block)
    @handlers[event_name] << block
  end

  def send_the_movie
    event_name = :movie_sign
    emit(event_name)
  end

  def disconnect
    event_name = :power_out
    emit(event_name)
  end

  def emit(event_name)
    @handlers[event_name].each do |handler|
      handler.call(self)
    end
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
    sol = SatelliteOfLove.new
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
    end.to yield_with_args(sol)
    expect do |b|
      sol.on(:power_out, &b)
      sol.disconnect
    end.to yield_with_args(sol)
  end
end
