require 'net/http'
require 'json'
require 'time'
require 'date'
require 'active_support'
require 'active_support/core_ext'

SCHEDULER.every '15s', :first_in => 0 do |job|
  http = Net::HTTP.new('fritz.nobreakspace.org', 8585)
  connectionSandStrFh = http.request(Net::HTTP::Get.new('/connection?from=707193&to=3460013&product=B&providerName=sh'))
  nextBusses = JSON.parse(connectionSandStrFh.body)

  deaptureDate = DateTime.parse(nextBusses[0]['plannedDepartureTime'])

  now = DateTime.now

  minutesToDepature = ((deaptureDate - now) * 24 * 60).to_i

  send_event('sanstrToUni', {current: minutesToDepature})
end
