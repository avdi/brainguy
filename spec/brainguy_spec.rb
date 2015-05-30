require "rspec"
require "set"
require "delegate"

class Subscription
  def initialize(owner, listener)
    @owner    = owner
    @listener = listener
  end

  def handle(event_source, event_name, extra_args)
    @listener.call(event_source, event_name, *extra_args)
  end

  def cancel
    @owner.delete(self)
  end
end

class SingleEventSubscription < Subscription
  def initialize(owner, listener, subscribed_event_name)
    super(owner, listener)
    @subscribed_event_name = subscribed_event_name
  end

  def handle(event_source, event_name, extra_args)
    return unless event_name == @subscribed_event_name
    super
  end
end

class FullSubscription < Subscription
end

class SubscriptionSet < DelegateClass(Set)
  def initialize
    super(Set.new)
  end

  def add_listener(new_listener)
    FullSubscription.new(self, new_listener).tap do |subscription|
      self << subscription
    end
  end
end

class SatelliteOfLove
  def initialize
    @subscriptions = SubscriptionSet.new
  end

  def on(event_name, &block)
    subscription = SingleEventSubscription.new(@subscriptions, block, event_name)
    @subscriptions << subscription
    subscription
  end

  def events
    @subscriptions
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

  private

  def emit(event_name, *extra_args)
    @subscriptions.each do |subscription|
      subscription.handle(self, event_name, extra_args)
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

  it "passes extra emit args on to the handler block" do
    sol        = SatelliteOfLove.new
    movie_info = :not_set
    sol.on(:movie_sign) do |object, event, info|
      movie_info = info
    end
    sol.send_final_sacrifice
    expect(movie_info[:origin]).to eq("Canada")
    expect(movie_info[:hero]).to eq("Zap Rowsdower")
  end

  it "allows a subscription to be removed" do
    sol = SatelliteOfLove.new
    expect do |b|
      subscription = sol.on(:movie_sign, &b)
      subscription.cancel
      sol.send_the_movie
    end.to_not yield_control
  end

  it "allows an object to listen to all events" do
    sol      = SatelliteOfLove.new
    listener = spy("listener")
    sol.events.add_listener(listener)

    sol.send_the_movie
    expect(listener).to have_received(:call).with(sol, :movie_sign)

    sol.disconnect
    expect(listener).to have_received(:call).with(sol, :power_out)
  end
end
