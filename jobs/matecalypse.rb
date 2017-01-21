require 'net/http'
require 'json'
require 'time'
require 'date'
require 'active_support'
require 'active_support/core_ext'

SCHEDULER.every '3600s', :first_in => 0 do |job|

  ary = ["4260031874056", "4029764001807", "4260401930238", "4027109007309"]

  http = Net::HTTP.new('icebox.nobreakspace.org', 8081)
  responseconsumtions30 = http.request(Net::HTTP::Get.new('/consumptions/30'))
  responsestock = http.request(Net::HTTP::Get.new('/drinks'))
  consumtions30 = JSON.parse(responseconsumtions30.body)
  stock = JSON.parse(responsestock.body)

  consumtionCounter = 0
  mateCounter = 0

  for i in 0..consumtions30.length-1
    if ary.include? consumtions30[i]['barcode']
      consumtionCounter = consumtionCounter + 1
    end
  end

  for i in 0..stock.length-1
    if ary.include? stock[i]['barcode']
      mateCounter = mateCounter + stock[i]["quantity"]
    end
  end
  
  send_event('matecalypse', {current: (mateCounter/(consumtionCounter/30.to_f)).to_i})

end
