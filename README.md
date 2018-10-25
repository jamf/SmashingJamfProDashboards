# SmashingJamfPro
Connect Smashing to your Jamf Pro instance

Copy of the Keynote used during the JNUC 2018 session: [JNUC 2018 Creating Smashing Dashboards](https://github.com/erinmc/SmashingJamfPro/blob/master/JNUC%202018%20SmashingDashboards.pdf)

Contains example jobs, example dashboard, and example YAML file. 

Requires the Hotness widget.  To get this run:
`smashing install 6246149`

#### Jobs
* computers.rb: Returns name and device count for an advanced computer search
* modellist.rb: Returns name of advanced search, list and count of models in an advanced computer search
* smartdevice.rb: Returns name of Smart Mobile Device group and count
* smartgroup.rb: Returns name of Smart Compuer group and count
* smartmeter.rb: Returns name of Smart Computer group, finds count of computers and calculates percentage of all managed computers to meter widget

