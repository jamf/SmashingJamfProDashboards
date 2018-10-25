#!/usr/bin/ruby

# Job to populate a Meter widget with the percentage of devices in a Smart Computer Group
# Percentage calculated against the total number of devices in 'All Managed Computers'

#Add required libraries

require 'net/http'
require 'uri'
require 'json'

config = YAML.load_file("lib/jamfpro.yml")
url = config['url']
allComputers = config['allcomps']
# Group we want to calculate the percentage of
percent1 = config['percentgroup1']

# Schedule job to do

# Get JSON from specific All managed computers smart group

SCHEDULER.every '5s', :first_in => 0 do |job|
uriAll = URI.parse("#{url}/JSSResource/computergroups/id/#{allComputers}")
requestAll = Net::HTTP::Get.new(uriAll)
requestAll.basic_auth(config['user'], config['password'])
requestAll["Accept"] = "application/json"

req_optionsAll = {
	use_ssl: uriAll.scheme == "https",
}
responseAll = Net::HTTP.start(uriAll.hostname, uriAll.port, req_optionsAll) do |httpAll|
	httpAll.request(requestAll)
	end
	
# Get JSON from smart group that you wish to get the percentage of

uri2 = URI.parse("#{url}/JSSResource/computergroups/id/#{percent1}")
request2 = Net::HTTP::Get.new(uri2)
request2.basic_auth(config['user'], config['password'])
request2["Accept"] = "application/json"

req_options2 = {
	use_ssl: uri2.scheme == "https",
}

response2 = Net::HTTP.start(uri2.hostname, uri2.port, req_options2) do |http2|
		http2.request(request2)	
end

# Check for HTTP Status OK.  

if (responseAll.code == "200") then
# If OK, get count of computers and name of smart group

devicecountAll = 0
devicecount2 = 0
	devicecountAll = JSON.parse(responseAll.body)['computer_group']['computers'].size
	searchnameAll = JSON.parse(responseAll.body)['computer_group']['name']
	devicecount2 = JSON.parse(response2.body)['computer_group']['computers'].size
	searchname2 = JSON.parse(response2.body)['computer_group']['name']
	#Start doing percent math
	comppercent = ((devicecount2.to_f / devicecountAll.to_f) * 100).round
	# .to_f ensures we have a float
	send_event(
		'percomp', 
		{ 
			value: comppercent,
			title: searchname2
		 })
	else
	
# If not OK, display status code in Smashing Output
	
	print "All Managed Computers ID: #{allComputers} Other smart group ID: #{percent1}"
	print "Percentage of #{searchname2} - Error: HTTP Status code #{response.code}"
	end

end
