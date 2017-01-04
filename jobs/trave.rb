#Wasserststand der Trave über die letzten 10 Tage
require 'open-uri'
require 'net/http'
require 'json'
require 'date'

pegelonline = 'pegelonline.wsv.de'
measurements = '/webservices/rest-api/v2/stations/L%C3%9CBECK-BAUHOF/W/measurements.json'
station = '/webservices/rest-api/v2/stations/L%C3%9CBECK-BAUHOF/W.json?includeCharacteristicValues=true'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '1m', :first_in => 0 do |job|

  http = Net::HTTP.new(pegelonline, 80)
  response = http.request(Net::HTTP::Get.new(measurements))
  travedata = JSON.parse(response.body)
  data = []
  #travedata[travedata.length-1]["value"]
  for i in 0..travedata.length-1
    data[i] = {"x" => i, "y" => travedata[i]["value"]-509.0}
  end
  if data.last["y"] > 0
    send_event(:trave, points: data, displayedValue: data.last["y"])
  else
    send_event(:trave, points: data, displayedValue: data.last["y"])
  end
end
