#!/usr/bin/ruby

# Job to populate a widget with the count of devices in an Advanced Computer Search

#Add required libraries

require 'net/http'
require 'uri'
require 'json'

config = YAML.load_file("lib/jamfpro.yml")
url = config['url']
advancedsearch1 = config['adv1']
# Schedule job to do

# Get JSON from specific Advanced Search 

uri = URI.parse("#{url}/JSSResource/advancedcomputersearches/id/#{advancedsearch1}")
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
# If OK, get count of computers and name of advanced search

	devicecount = JSON.parse(response.body)['advanced_computer_search']['computers'].size
	searchname = JSON.parse(response.body)['advanced_computer_search']['name']
	send_event(
		'compcount', 
		{ 
			value: devicecount,
			title: searchname
		 })
	else
	
# If not OK, display status code in Smashing Output

	puts "Search #: #{advancedsearch1}"
	puts "Error: HTTP Status code #{response.code}"
	end

end

