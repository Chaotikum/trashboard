require 'open-uri'

sensors_url = 'http://troll.nobreakspace.org/sensors.html'

SCHEDULER.every '30s', :first_in => 0 do |job|
  open(sensors_url).read() =~ /heizung_x<\/td><td.*?>([\d.]+)/

  temperature = Float($1)
  
  send_event('temperatur', {current: temperature})
end
