#180 µg/m3

require 'rubygems'
require 'open-uri'
require 'csv'

SCHEDULER.every '1m', :first_in => 0 do |job|
  data = []

  d = DateTime.now()
  d2 = d - 7;

  umweltbundesamt = 'http://www.umweltbundesamt.de/luftdaten/data.csv?pollutant=O3&data_type=1SMW&date='+d2.strftime("%Y%m%d")+'&dateTo='+d.strftime("%Y%m%d")+'&station=DESH023'

  CSV.new(open(umweltbundesamt), :headers => :first_row).each do |line|
    data[data.length] = {"x" => setToBeginningOfDay(d2).to_i+(3600*data.length), "y" => line[0].split( /; */ )[2].to_i}
  end

  for i in 0..data.length-1
    if data[i]["y"] < 0
      data[i]["y"] = data[i-1]["y"]
    end
  end
 if data.last["y"] > 0
   send_event(:ozon, points: data, displayedValue: data.last["y"])
 else
   send_event(:ozon, points: data, displayedValue: data.last["y"])
 end
end

def setToBeginningOfDay(datetime)
    DateTime.strptime(datetime.strftime("%Y-%m-%d")+"T00:00:00+01:00")
end
