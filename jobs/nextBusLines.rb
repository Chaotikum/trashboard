require 'net/http'
require 'json'
require 'time'
require 'date'
require 'active_support'
require 'active_support/core_ext'

class Depature
  def initialize(from, to, busline, time)
    @c_from = from
    @c_to = to
    @c_busline = busline
    @c_time = time
  end

  def getTime
    return @c_time
  end

  def getBusLine
    return @c_busline
  end

  def getTo
    return @c_to
  end

  def getFrom
    return @c_from
  end
end

sandstrasse = '/departure?from=707193&providerName=sh&limit=20'
wahmstrasse = '/departure?from=707213&providerName=sh&limit=20'

connectionsOfInterest = [sandstrasse, wahmstrasse]
startstaions = ['Sandstraße', 'Wahmstraße']
rides = [];
relevantLines = ['9', '6', '1', '4', '5', '10', '11']

SCHEDULER.every '120s', :first_in => 0 do |job|
  rides = [];
  http = Net::HTTP.new('fritz.nobreakspace.org', 8585)

  for i in 0..connectionsOfInterest.length-1
    busLines = http.request(Net::HTTP::Get.new(connectionsOfInterest[i]))
    if(!(busLines.body == 'EFA error status: INVALID_STATION'))
      nextBusses = JSON.parse(busLines.body)
      for j in 0..nextBusses.length-1
        dep = Depature.new(startstaions[i], nextBusses[j]['to'], nextBusses[j]['number'], nextBusses[j]['departureTime'])
        rides.push(dep);
      end
      sleep 10
    end
  end

  relevantRides = []

  if(rides.length == 40)

    for i in 0..rides.length-1
      if(relevantLines.include? rides[i].getBusLine)
          relevantRides.push(rides[i])
      end
    end

    relevantRides = relevantRides.sort_by {|obj| obj.getTime}

    send_event('nextConnextions', { items: relevantRides.take(10).map { |d| {label: d.getBusLine+' nach '+d.getTo[0,10], value: DateTime.parse(d.getTime).strftime("%H:%M") }}})
  end
end
