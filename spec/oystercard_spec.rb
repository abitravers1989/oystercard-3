require 'oystercard'
require 'station'

describe Oystercard do

  # let(:station) { double :station }

  it 'initializes with a zero balance' do
    expect(described_class.new.balance).to eq 0
  end

  it 'can top up the balance' do
    subject.top_up(20)
    expect(subject.balance).to eq 20
  end

  it 'can top up the balance' do
    expect { subject.top_up 1 }.to change { subject.balance }.by 1
  end

  it 'cannot be touched in without a minimun balance of £1' do
    # min_bal = described_class::MIN_BAL
    subject.top_up(0.5)
    station = Station.new("Paddington", 1)
    expect { subject.touch_in(station) }.to raise_error "Insufficient funds to touch in, balance must be more than/
    #{MIN_BAL}"
  end

  it 'raises an error if balance exceeds 90' do
    max_lim = described_class::MAXIMUM_LIMIT
    card = described_class.new
    card.top_up(max_lim)
    expect { card.top_up 1 }.to raise_error "Max balance £#{max_lim} exceeded"
  end

  it 'is in journey' do
    expect(subject).to respond_to(:in_journey?)
  end

  it 'has a default status of not in use' do
    expect(subject.in_journey?).to eq 'not in use'
  end

  let(:station) { double :station }
  it 'can record touch in station' do
    subject.top_up(5)
    # station = Station.new("Paddington")
    allow(station).to receive_messages(name: "Paddington", zone: 1)
    subject.touch_in(station)
    expect(subject.journeys).to eq([{ in: "Paddington", zone: 1}])
  end

  it 'has an empty list of journeys by default' do 
    expect(subject.journeys).to eq []
  end

  context "is topped up and has touched in" do 
    before(:each) do
      subject.top_up(10)
      station1 = Station.new("Paddington", 1)
      subject.touch_in(station1)
    end

    it 'can deduct the balance when touching out' do
      station2 = Station.new("Aldgate", 1)
      expect { subject.touch_out(station2) }.to change { subject.balance }.by(-Oystercard::FARE_PER_TRIP)
    end

    it 'changes its status to in use after touch in' do
      expect(subject.in_journey?).to eq 'in use'
    end
  end

  context "has 1 complete journey" do 
    before(:each) do
      subject.top_up(10)
      station1 = Station.new("Paddington", 1)
      station2 = Station.new("Bank", 1)
      subject.touch_in(station1)
      subject.touch_out(station2)
    end
    
    it 'will reduce the balance by a specified amount' do
      expect(subject.balance).to eq 9
    end

    it 'changes its status to not in use after touch out' do
      expect(subject.in_journey?).to eq 'not in use'
    end

    # it 'records journeys' do
    #   expect(subject.journeys).to eq([{ in: "Paddington", out: "Bank" }])
    # end

    it 'creates one journey when touching in then out' do
      expect(subject.journeys.length).to eq subject.trip_no
    end

  end
  
end
