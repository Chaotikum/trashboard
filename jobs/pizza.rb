require 'net/http'
require 'json'
require 'time'
require 'date'
require 'active_support'
require 'active_support/core_ext'

blubberkram = '/messages'

http = Net::HTTP.new('fritz.nobreakspace.org', 17799)

SCHEDULER.every '10s', :first_in => 0 do |job|

  result = http.request(Net::HTTP::Get.new(blubberkram))

  resultS = JSON.parse(result.body)

  data = []

  for j in 0..resultS.length-1
    puts resultS[j]
  end

  resultS = resultS.sort_by.reverse {|obj| obj['createdAt']}.reverse!

  send_event('pizza', { items: resultS.take(10).map { |d| {label: DateTime.parse(d['createdAt']).strftime("%d.%m.%y %H:%M"), value: d['message'] }}})

end
