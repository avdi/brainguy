require "brainguy"

class SatelliteOfLove
  include Brainguy::Observable

  def intro_song
    emit(:robot_roll_call)
  end

  def send_the_movie
    emit(:movie_sign)
  end
end

class Crew
  include Brainguy::Observer
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
