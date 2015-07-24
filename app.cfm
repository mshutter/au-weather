<!---
	<link rel="stylesheet" href="./css/weather-icons.min.css">
--->
<style>
	.AAA,
	.AAA-only {
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

<cfset current = APPLICATION.weatherData.currently />
<cfset daily   = APPLICATION.weatherData.daily.data />



<div class="wthr-container">

	<!---
		Current Weather
	--->
	
	<div class="wthr-row">
	<div class="wthr-current">
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
				#current.summary#
			</span>
			<br />

			<span class='wthr-icon'>
				<i class='#iconClassRef[ current.icon ]#' aria-hidden='true'></i>
			</span>

			<span class="wthr-temperature">
				#Round( current.temperature )#&deg;F
			</span>
			<br />

			<span class="wthr-feels-like">
				(Feels like <span>
					#Round( current.apparentTemperature )#&deg;F
				</span>)
			</span>
		</div>
		
		<ul class='wthr-details'>
			<li class='wthr-precipitation'>
				<label>
					<span class="AAA">Chance of precipitation:</span>
					<i class='wi wi-sprinkles' aria-hidden='true'></i>
				</label>

				#Round( current.precipProbability )#&percnt;
			</li>

			<li class='wthr-cloud-cover'>
				<label>
					<span class="AAA">Cloud coverage:</span>
					<i class='wi wi-cloud' aria-hidden='true'></i>
				</label>
				
				#current.cloudCover * 100#&percnt;
			</li>
			
			<!--- Note:
				Class _xxx-deg uses CSS3 transform to rotate wind-bearing icon xxx degrees
				clockwise, where xxx is any multiple of 15 between 0 and 345. The equation
				in the following section will round the current windBearing variable accordingly
				before applying this class.

				One may also note that if this equation evaluates to 360 the class will not
				be recognized, but there will be no need to rotate the icon in this state,
				as it will default to 0 degrees.
			--->

			<li class='wthr-wind'>
				<label>
					<span class="AAA">Wind Speed:</span>
					<i class='wi wi-wind-default _#Round( current.windBearing / 15 ) * 15#-deg' aria-hidden='true'></i>
				</label>
				
				#Round( current.windSpeed * 10 ) / 10# mph
			</li>
		</ul>
	</cfoutput>
	</div> <!-- .wthr-current -->
	</div> <!-- .wthr-row -->


	<!---
		Daily forecast thumbnails
	--->

	<div class='wthr-row'>
	<div class='wthr-daily'>
	<cfoutput>
		<div class="wthr-table">
		<cfloop from='1' to='6' index='i'>

			<div class='wthr-day-thumb' id='wthr-day-thumb-#i#'>
				<span class='wthr-date'>
					#DateFormat(
						EpochTimeToDate( daily[i].time ),
						'ddd'
					)#
				</span>
				
				<!-- icon alternative for acessability -->
				<span class="AAA-only">
					#daily[i].summary#
				</span>

				<span class='wthr-icon'>
					<i class='#iconClassRef[ daily[i].icon ]#' aria-hidden='true'></i>
				</span>

				<span class="wthr-min">
					#Round( daily[i].temperatureMin )#
				</span>

				<span class="wthr-max">
					#Round( daily[i].temperatureMax )#
				</span>
			</div>

		</cfloop>
		</div> <!-- .wthr-table -->
	</cfoutput>
	</div> <!-- .wthr-daily -->
	</div> <!-- .wthr-row -->


	<!---
		Daily forecast details
	--->

	<div class="wthr-row">
	<cfloop from='1' to='1' index='i'>
		<div class="wthr-daily-details" id='wthr-details-#i#'>
		<cfoutput>
		

			<div class='wthr-details-header'>
				<h5>
					#DateFormat(
						EpochTimeToDate( daily[i].time ),
						'dddd, mmmm dd, yyyy'
					)#
				</h5>

				<span class='wthr-summary'>
					#daily[i].summary#
				</span>
			</div>
			
			<ul class='wthr-data'>
				<li class="wthr-chance-of-precip">
					<label>Chance of precipitation</label>
					#Round( daily[i].precipProbability )#&percnt;
				</li>

				<li class='wthr-cloud-cover'>
					<label>Cloud cover</label>
					#current.cloudCover * 100#&percnt;
				</li>

				<li class="wthr-humidity">
					<label>Humidity</label>
					#Round( daily[i].humidity * 100 )#&percnt;
				</li>
				
				<!--- Conditional accomodates for missing visibility information (only given for first 5 days) --->
				<cfif StructKeyExists( VARIABLES.daily[i], 'visibility' )>
					<li class="wthr-visibility">
						<label>Visibility</label>
						#Round( daily[i].visibility * 10 ) / 10#<cfif daily[i].visibility GTE 10>+</cfif>
						mile<cfif daily[i].visibility GT 1>s</cfif>
					</li>
				</cfif>
				
				<li class='wthr-wind'>
					<label>Wind</label>
					#Round( daily[i].windSpeed * 10 ) / 10# mph
					<i class='wi wi-wind-default _#Round( daily[i].windBearing / 15 ) * 15#-deg' aria-hidden='true'></i>
				</li>

				<li class="wthr-sunrise">
					<label>Sunrise</label>
					#TimeFormat(
						EpochTimeToDate( daily[i].sunriseTime ),
						'h:mm tt'
					)#
				</li>

				<li class="wthr-sunset wthr-last">
					<label>Sunset</label>
					#TimeFormat(
						EpochTimeToDate( daily[i].sunsetTime ),
						'h:mm tt'
					)#
				</li>
			</ul> <!-- .wthr-data -->

		</cfoutput>
		</div> <!-- .wthr-daily-details -->
	</cfloop>
	</div> <!-- .wthr-row -->

</div> <!-- .wthr-container -->


<cfdump var='#APPLICATION.weatherData#' />