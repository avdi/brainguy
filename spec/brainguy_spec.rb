require "rspec"
require "brainguy"

module Brainguy
  class AuctionBid
    attr_reader :events

    def initialize
      @events = Brainguy::SubscriptionSet.new(self)
    end

    def reject_bid
      events.emit(:rejected)
    end

    def make_counter_offer
      events.emit(:rejected, counter_amount: 101, valid_for_minutes: 60)
    end

    def accept_bid
      events.emit(:accepted)
    end
  end

  RSpec.describe Brainguy do
    it "enables objects to publish simple events" do
      mike = spy("mike")
      bid  = AuctionBid.new
      bid.events.on(:rejected) do
        mike.handle_rejection
      end
      bid.reject_bid
      expect(mike).to have_received(:handle_rejection)
    end

    it "allows multiple listeners to subscribe" do
      mike = spy("mike")
      crow = spy("crow")
      bid  = AuctionBid.new
      bid.events.on(:rejected) do
        mike.handle_rejection
      end
      bid.events.on(:rejected) do
        crow.handle_rejection
      end
      bid.reject_bid
      expect(mike).to have_received(:handle_rejection)
      expect(crow).to have_received(:handle_rejection)
    end

    it "allows multiple events to be emitted" do
      crow = spy("crow")
      bid  = AuctionBid.new
      bid.events.on(:rejected) do
        crow.handle_rejection
      end
      bid.events.on(:accepted) do
        crow.handle_acceptance
      end
      bid.reject_bid
      expect(crow).to have_received(:handle_rejection)
      expect(crow).to_not have_received(:handle_acceptance)
      bid.accept_bid
      expect(crow).to have_received(:handle_acceptance)
    end

    it "allows for zero subscribers" do
      bid = AuctionBid.new
      expect { bid.reject_bid }.to_not raise_error
    end

    it "passes the event emitting object to handler blocks" do
      bid = AuctionBid.new
      expect do |b|
        bid.events.on(:rejected, &b)
        bid.reject_bid
      end.to yield_with_args(bid, anything)
      expect do |b|
        bid.events.on(:accepted, &b)
        bid.accept_bid
      end.to yield_with_args(bid, anything)
    end

    it "passes the event name to handler blocks" do
      bid = AuctionBid.new
      expect do |b|
        bid.events.on(:rejected, &b)
        bid.reject_bid
      end.to yield_with_args(anything, :rejected)
    end

    it "passes extra event args on to the handler block" do
      bid = AuctionBid.new
      expect do |b|
        bid.events.on(:rejected, &b)
        bid.make_counter_offer
      end.to yield_with_args(anything, anything,
                             {counter_amount:    101,
                              valid_for_minutes: 60})
    end

    it "allows a subscription to be removed" do
      bid = AuctionBid.new
      expect do |b|
        subscription = bid.events.on(:rejected, &b)
        subscription.cancel
        bid.reject_bid
      end.to_not yield_control
    end

    it "allows an object to listen to all events" do
      bid      = AuctionBid.new
      listener = spy("listener")
      bid.events.subscribe(listener)

      bid.reject_bid
      expect(listener).to have_received(:call).with(bid, :rejected)

      bid.accept_bid
      expect(listener).to have_received(:call).with(bid, :accepted)
    end

    it "allows a listener to be unsubscribed" do
      bid          = AuctionBid.new
      listener     = spy("listener")
      subscription = bid.events.subscribe(listener)

      bid.reject_bid
      expect(listener).to have_received(:call).with(bid, :rejected)

      subscription.cancel

      bid.accept_bid
      expect(listener).not_to have_received(:call).with(bid, :accepted)
    end

    it "allows a listener to be unsubscribed by identity" do
      bid      = AuctionBid.new
      listener = spy("listener")
      bid.events.subscribe(listener)

      bid.reject_bid
      expect(listener).to have_received(:call).with(bid, :rejected)

      bid.events.unsubscribe(listener)
      expect(bid.events).to be_empty

      bid.accept_bid
      expect(listener).not_to have_received(:call).with(bid, :accepted)
    end

    it "does not allow the same listener to be subscribed twice" do
      bid      = AuctionBid.new
      listener = spy("listener")
      bid.events.subscribe(listener)
      bid.events.subscribe(listener)
      bid.reject_bid
      expect(listener).to have_received(:call).once
    end
  end
end
