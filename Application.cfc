<cfcomponent>

	<cffunction name='onRequestStart'>
		<cfif
			!IsDefined( 'APPLICATION.timeOfLatestWeatherCall' )
			OR
			DateDiff( 'n', APPLICATION.timeOfLatestWeatherCall, now() ) GT 2
		>
			<cfhttp
				url='https://api.forecast.io/forecast/731217e623202573f07be933096f16fa/42.2556,-77.7892'
				method='get'
				result='weatherData' />
			<cfset APPLICATION.weatherData = DeserializeJSON( weatherData.fileContent ) />
			<cfset APPLICATION.timeOfLatestWeatherCall = now() />
		</cfif>
	</cffunction>

</cfcomponent>