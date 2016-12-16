# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '1m', :first_in => 0 do |job|
  send_event('catimage', {image: 'http://thecatapi.com/api/images/get?' + rand(15003).to_s})
end
