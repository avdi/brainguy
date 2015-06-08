# Brainguy

![Observer, AKA "Brain Guy"](http://static.tvtropes.org/pmwiki/pub/images/MST3K_Brain_Guy_7093.jpg)

Brainguy is an Observer library for Ruby.

## Synopsis

```ruby
require "brainguy"

class SatelliteOfLove
  include Brainguy::Eventful

  def intro_song
    emit(:robot_roll_call)
  end

  def send_the_movie
    emit(:movie_sign)
  end
end

class Crew
  include Brainguy::Listener
end

class TomServo < Crew
  def on_robot_roll_call(event)
    puts "Tom: Check me out!"
  end
end

class CrowTRobot < Crew
  def on_robot_roll_call(event)
    puts "Crow: I'm different!"
  end
end

class MikeNelson < Crew
  def on_movie_sign(event)
    puts "Mike: Oh no we've got movie sign!"
  end
end

sol = SatelliteOfLove.new
# Attach specific event handlers without a listener object
sol.on(:robot_roll_call) do
  puts "[Robot roll call!]"
end
sol.on(:movie_sign) do
  puts "[Movie sign flashes]"
end
sol.events.attach TomServo.new
sol.events.attach CrowTRobot.new
sol.events.attach MikeNelson.new

sol.intro_song
sol.send_the_movie

# >> [Robot roll call!]
# >> Tom: Check me out!
# >> Crow: I'm different!
# >> [Movie sign flashes]
# >> Mike: Oh no we've got movie sign!

```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'brainguy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install brainguy

## Usage

Coming soon!

## Contributing

1. Fork it ( https://github.com/[my-github-username]/brainguy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
