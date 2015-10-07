<cfcomponent>

	<!--- At the start of every request... --->
	<cffunction name='onRequestStart'>

		<!--- Note:
			For more information on how Dark Sky Forecast API works, please visit: https://developer.forecast.io/docs/v2.
		--->

		<!--- check if a call to api.forecast.io has been made in the last two minutes. --->
		<cfif
			!IsDefined( 'APPLICATION.timeOfLatestWeatherCall' )
			OR
			DateDiff( 'n', APPLICATION.timeOfLatestWeatherCall, now() ) GT 2
		>

			<!--- If not, make a new call... --->
			<cfhttp
				url='https://api.forecast.io/forecast/731217e623202573f07be933096f16fa/42.2556,-77.7892'
				method='get'
				result='weatherData' />

			<!--- use the data to update APPLICATION.weatherData... --->
			<cfset APPLICATION.weatherData = DeserializeJSON( weatherData.fileContent ) />

			<!--- and reset the time of latest call to the current time. --->
			<cfset APPLICATION.timeOfLatestWeatherCall = now() />
		</cfif>
	</cffunction>

</cfcomponent>