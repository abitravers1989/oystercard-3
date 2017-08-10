require_relative './station.rb'

MIN_BAL = 1

class Oystercard
  attr_reader :balance, :journeys
  attr_accessor :journeys, :trip_no

  MAXIMUM_LIMIT = 90
  # DEFAULT_STATUS = false
  FARE_PER_TRIP = 1

  def initialize(maximum_limit = MAXIMUM_LIMIT)
    @balance = 0
    @maximum_limit = maximum_limit
    # @in_use = in_use
    @journeys = []
    @trip_no = 0
  end

  def top_up(amount)
    max_error if @balance + amount > @maximum_limit
    @balance += amount
  end

  def max_error
    raise 'Max balance £90 exceeded'
  end

  def in_journey?
    return 'not in use' if @journeys == []
    return 'in use' if @journeys.last[:out] == "nil"
    return 'not in use' if @journeys.last[:out] != nil
    # @journeys.last[:out] == @name
  end

  def touch_in(station)
    @trip_no += 1
    raise "Insufficient funds to touch in, balance must be more than/
    #{MIN_BAL}" if @balance < MIN_BAL
    # @in_use = true
    puts "Card touched in."
    @journeys << { in: station.name, zone: station.zone }
    # [@trip_no] taken out to add out station to the array
  end

  def touch_out(station)
    @trip_no += 1
    deduct(FARE_PER_TRIP)
    # @in_use = false
    puts "Card touched out. Remaining balance #{@balance}."
    @journeys << { out: station.name, zone: station.zone }
  end

private
  def deduct(amount)
    @balance -= amount
  end
end
