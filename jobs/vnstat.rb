require 'net/http'
require 'xmlsimple'

SCHEDULER.every '1m', :first_in => 0 do |job|
  http = Net::HTTP.new('router.nobreakspace.org')
  response = http.request(Net::HTTP::Get.new('/cgi-bin/vnstat'))
  traffic = XmlSimple.xml_in(response.body, { 'AttrPrefix' => true, 'KeyAttr' => '@id' })['interface']['ppp0']['traffic'][0]
  months = traffic["months"][0]
  days = traffic["days"][0]

  data = days['day']["0"]
  tx = data["tx"][0].to_i
  rx = data["rx"][0].to_i
  total = tx + rx # KiB
  data = days['day']["1"]
  tx = data["tx"][0].to_i
  rx = data["rx"][0].to_i
  last = tx + rx # KiB
  send_event('today', { current: total / (1024), last: last / 1024 })

  data = months['month']["0"]
  tx = data["tx"][0].to_i
  rx = data["rx"][0].to_i
  total = tx + rx # KiB
  data = months['month']["1"]
  tx = data["tx"][0].to_i
  rx = data["rx"][0].to_i
  last = tx + rx # KiB
  send_event('this_month', { current: total / (1024**2), last: last / (1024**2) })
end
