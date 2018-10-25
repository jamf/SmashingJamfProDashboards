#!/usr/bin/ruby

# Job to populate a List widget with the results of an Advanced Computer Search
# Required: Advanced search must be set to display 'Model' as part of the results

#Add required libraries

require 'net/http'
require 'uri'
require 'json'

# Read YAML file for Jamf Pro data

config = YAML.load_file("lib/jamfpro.yml")
url = config['url']
listsearch = config['listadv']

# Schedule job to do

# Get JSON from specific Advanced Search 

uri = URI.parse("#{url}/JSSResource/advancedcomputersearches/id/#{listsearch}")
request = Net::HTTP::Get.new(uri)
request.basic_auth(config['user'],config['password'])
request["Accept"] = "application/json"

req_options = {
	use_ssl: uri.scheme == "https",
}
SCHEDULER.every '5s', :first_in => 0 do |job|
response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
	http.request(request)
end

# Check response for http 200 (OK) and print the output

if (response.code == "200") then
	# Parse http response using above library	

	# Iterate through each of the rows above
	model_count = Hash.new(0)
	model_sorted_count = Hash.new(0)
	searchname = JSON.parse(response.body)['advanced_computer_search']['name']
	JSON.parse(response.body)['advanced_computer_search']['computers'].each do |models|
	
	# Increment the counter for this particular Model type
		model_count[models["Model"]] += 1

	end

	# Sort the array by value from most to least and print each line:

	model_count.keys.sort_by { |key| model_count[key] }.reverse.each do |key|
		
#Uncomment the next line to run debug and show the output that will be sent to Smashing
		#print key + " = " + model_count[key].to_s + "\n"
		model_sorted_count[key] = { label: key,
		value: (model_count[key].to_i)}
		
	end
# Send the event to smashing widget:
	send_event('modelcount', { items: model_sorted_count.values, 
								title: searchname})
	else 
	# Display error messages in Smashing Output
	puts "Advanced Search ID: #{listsearch}"
	puts "Error: HTTP Status code #{response.code} for model list"
	end
end
