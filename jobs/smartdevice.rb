#!/usr/bin/ruby

# Job to populate a Number (or similar type) widget with the count of a Smart Device Group

#Add required libraries

require 'net/http'
require 'uri'
require 'json'

config = YAML.load_file("lib/jamfpro.yml")
url = config['url']
msmartgroup = config['msg1']

# Schedule job to do

# Get JSON from specific Mobile Device Smart Group

uri = URI.parse("#{url}/JSSResource/mobiledevicegroups/id/#{msmartgroup}")
request = Net::HTTP::Get.new(uri)
request.basic_auth(config['user'], config['password'])
request["Accept"] = "application/json"

req_options = {
	use_ssl: uri.scheme == "https",
}
SCHEDULER.every '5s', :first_in => 0 do |job|
response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
	http.request(request)
end

# Check for HTTP Status OK.  

if (response.code == "200") then
# If OK, get count of devices and name of smart group

	devicecount = JSON.parse(response.body)['mobile_device_group']['mobile_devices'].size
	searchname = JSON.parse(response.body)['mobile_device_group']['name']
	send_event(
		'smartdevice', 
		{ 
			value: devicecount,
			title: searchname
		 })
	else
	
# If not OK, display status code in Smashing Output
	puts "Smart Device Group ID: #{msmartgroup}"
	puts "#{searchname} - Error: HTTP Status code #{response.code}"
	end

end

