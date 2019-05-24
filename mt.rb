# Attempt to imitate Mersenne Twister random number generator in ruby
# Jason Wang 2019
# based on JS implementation found here https://create.stephan-brumme.com/mersenne-twister/

# To use, specify seed at the bottom
# To get within a certain range x, m.random % x
# To test, ruby mt.rb

# NOTES
# x.to_s(2) to get the binary representation of an integer.
# 
# difference between >> and >>>, >> is signed where >>> is unsigned,
# meaning >> keeps the first bit when shifting, whereas >>> always uses 0,
# the left most bit represents whether the value is negative or positive.
class MersenneTwister
  def initialize(seed = nil)
    @next = 0
    @state = Array.new(624)
    @seed = seed || 5489 # default seed
    init
  end

  # initialize the state with the seed
  def init
    @state[0] = @seed;
    (1..623).each do |i|
      s = @state[i - 1] ^ (@state[i - 1] >> 30)
      @state[i] = (((((s & 0xffff0000) >> 16) * 1812433253) << 16) + (s & 0x0000ffff) * 1812433253) + i
      @state[i] |= 0
    end
    twist
  end

  def twist
    # first 227 words
    (0..226).each do |i|
      bits = (@state[i] & 0x80000000) | (@state[i + 1] & 0x7fffffff)
      @state[i] = @state[i + 397]^(bits >> 1)^((bits & 1) * 0x9908b0df)
    end

    # 227 to 622 words
    (227..622).each do |i|
      bits = (@state[i] & 0x80000000) | (@state[i + 1] & 0x7fffffff)
      @state[i] = @state[i - 227]^(bits >> 1)^((bits & 1) * 0x9908b0df)
    end

    # last word
    bits = (@state[623] & 0x80000000) | (@state[0] & 0x7fffffff)
    @state[623] = @state[396] ^ (bits >> 1) ^ ((bits & 1) * 0x9908b0df)
    @next = 0
  end

  def random
    twist if @next >= 624
    x = @state[@next += 1] # get and increment next too
    # shuffle bits
    x = x ^ (x >> 11)
    x = x ^ ((x << 7) & 0x9d2c5680)
    x = x ^ ((x << 15) & 0xefc60000)
    x = x ^ (x >> 18)
    x
  end
end

# Main
m = MersenneTwister.new(Time.now.to_i) # hardcode with seed for repeatable values
puts m.random % 32
puts m.random % 32
