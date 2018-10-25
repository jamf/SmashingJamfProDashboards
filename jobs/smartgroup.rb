#!/usr/bin/ruby

# Job to populate a Number (or similar type) widget with the count of a Smart Computer Group

#Add required libraries

require 'net/http'
require 'uri'
require 'json'

config = YAML.load_file("lib/jamfpro.yml")
url = config['url']
smartgroup1 = config['cgroup1']
# Schedule job to do

# Get JSON from specific Smart Computer Gorup

uri = URI.parse("#{url}/JSSResource/computergroups/id/#{smartgroup1}")
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
# If OK, get count of computers and name of smart group

	devicecount = JSON.parse(response.body)['computer_group']['computers'].size
	searchname = JSON.parse(response.body)['computer_group']['name']
	send_event(
		'allcomps', 
		{ 
			value: devicecount,
			title: searchname
		 })
	else
	
# If not OK, display status code in Smashing Output
	
	print "Smart Compuer Group ID: #{smartgroup1}"
	print "#{searchname} - Error: HTTP Status code #{response.code}"
	end

end
