require 'rubygems'
require 'open-uri'
require 'csv'

SCHEDULER.every '1m', :first_in => 0 do |job|
  data = []

  d = DateTime.now()
  d2 = d - 14;

  umweltbundesamt = 'http://www.umweltbundesamt.de/luftdaten/data.csv?pollutant=PM1&data_type=1TMW&date='+d2.strftime("%Y%m%d")+'&dateTo='+d.strftime("%Y%m%d")+'&station=DESH023'

  CSV.new(open(umweltbundesamt), :headers => :first_row).each do |line|
    data[data.length] = {"x" => d2.strftime('%s').to_i+(86400*data.length.to_i), "y" => line[0].split( /; */ )[2].to_i}
  end

 if data.last["y"] > 0
   send_event(:feinstaub, points: data, displayedValue: data.last["y"])
 else
   send_event(:feinstaub, points: data, displayedValue: data.last["y"])
 end
end
