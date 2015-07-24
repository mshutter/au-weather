<!---
	<link rel="stylesheet" href="./css/weather-icons.min.css">
--->
<style>
	.AAA {
		display: none;
	}
</style>

<!--- Script for using UNIX time variables in CF --->
<cfscript>
	/**
	 * Converts a UNIX epoch time to a ColdFusion date object.
	 * 
	 * @param epoch 	 Epoch time, in seconds. (Required)
	 * @return Returns a date object. 
	 * @author Chris Mellon (mellon@mnr.org) - Revised by Michael Shutter
	 * @version 1, June 21, 2002 
	 */
	function EpochTimeToDate(epoch) {
			// Convert to ColdFusion object
	    cfDateTime = DateAdd("s", epoch, "January 1 1970 00:00:00");

	    // Convert GMT to EST
	    return DateAdd('h', -4, cfDateTime);
	}
</cfscript>


<!--- WeatherIcon class references, based on API icon value --->
<cfset iconClassRef = {
	          'clear-day' = 'wi wi-day-sunny',
	        'clear-night' = 'wi wi-night-clear',
	               'rain' = 'wi wi-rain',
	               'snow' = 'wi wi-snow',
	              'sleet' = 'wi wi-sleet',
	               'wind' = 'wi wi-cloudy-gusts',
	                'fog' = 'wi wi-fog',
	             'cloudy' = 'wi wi-cloudy',
	  'partly-cloudy-day' = 'wi wi-day-cloudy',
	'partly-cloudy-night' = 'wi wi-night-cloudy'
} />

<cfset now   = APPLICATION.weatherData.currently />
<cfset today = APPLICATION.weatherData.daily.data[1] />
<cfset daily = APPLICATION.weatherData.daily.data />



<div class="wthr-container">

	<!---
		Header
	--->

	<div classs='wthr-header'>
		<h3>Alfred, NY</h3>
	</div>


	<!---
		Current Weather
	--->

	<div class="wthr-now">
	<cfoutput>
		<h4 class='wthr-current-time'>
			#DateFormat(
				now(),
				'dddd'
			)# #TimeFormat(
				now(),
				'hh:mm tt'
			)#
		</h4>
		<hr />

		<div class="wthr-climate">
			<span class='wthr-summary'>
				#now.summary#
			</span>
			<br />

			<span class='wthr-icon'>
				<i class='#iconClassRef[ now.icon ]#' aria-hidden='true'></i>
			</span>

			<span class="wthr-temperature">
				#Round( now.temperature )#&deg;F
			</span>
			<br />

			<span class="wthr-feels-like">
				(Feels like <span>
					#Round( now.apparentTemperature )#&deg;F
				</span>)
			</span>
		</div>
		
		<ul class='wthr-details'>
			<li class='wthr-precipitation'>
				<label>
					<span class="AAA">Chance of Precipitation:</span>
					<i class='wi wi-sprinkles' aria-hidden='true'></i>
				</label>

				#Round( now.precipProbability )#&percnt;
			</li>

			<li class='wthr-cloud-cover'>
				<label>
					<span class="AAA">Cloud Coverage:</span>
					<i class='wi wi-cloud' aria-hidden='true'></i>
				</label>
				
				#now.cloudCover * 100#&percnt;
			</li>
			
			<li class='wthr-wind'>
				<label>
					<span class="AAA">Wind Speed:</span>
					<i class='wi wi-wind-default _#Round( now.windBearing / 15 ) * 15#-deg' aria-hidden='true'></i>
				</label>
				
				#Round( now.windSpeed * 10 ) / 10#mph
			</li>
		</ul>
	</cfoutput>
	</div> <!-- .wthr-now -->

	<div class='wthr-today'>
	<cfoutput>
		<span class='wthr-sunrise'>
			<span class="AAA">Sunrise:</span>
			<i class='wi wi-sunrise' aria-hidden='true'></i>
			#TimeFormat(
				EpochTimeToDate( today.sunriseTime ),
				'h:mm tt'
			)#
		</span>

		<span class='wthr-sunset'>
			<span class='AAA'>Sunset:</span>
			<i class='wi wi-sunset' aria-hidden='true'></i>
			#TimeFormat(
				EpochTimeToDate( today.sunsetTime ),
				'h:mm tt'
			)#
		</span>
	</cfoutput>
	</div> <!-- .wthr-today -->
	
</div>


<cfdump var='#APPLICATION.weatherData#' />