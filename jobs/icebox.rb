require 'net/http'
require 'json'
require 'time'
require 'date'
require 'active_support'
require 'active_support/core_ext'

SCHEDULER.every '15s', :first_in => 0 do |job|
  http = Net::HTTP.new('icebox.nobreakspace.org', 8081)
  response = http.request(Net::HTTP::Get.new('/consumptions/1'))
  drinks = JSON.parse(response.body)
  counts = Hash.new(0)

  now = DateTime.now
  start = now.midnight
  if now.hour >= 4
	start += 4.hours
  else
	start -= 20.hours
  end

  drinks = drinks.select { |d|
	  ts = DateTime.parse(d['consumetime'])
	  ts > start
  }
  drinks.each { |d| counts[d['name']] += 1 }
  list = counts.sort_by {|_key, value| -value}

  send_event('drinklist', { items: list.map { |d| {label: d[0], value: d[1] }}})
  send_event('drinks', { current: drinks.length })

  http = Net::HTTP.new('icebox.nobreakspace.org', 8081)
  response = http.request(Net::HTTP::Get.new('/drinks'))
  bestand = JSON.parse(response.body)
  bestand = bestand.select { |d| d['quantity'] > 0 }
  bestand = bestand.sort_by {|d| -d['quantity'] }
  send_event('bestand', { items: bestand.map { |d| {label: d['name'], value: d['quantity'] }}})
end
