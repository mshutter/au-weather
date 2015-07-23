<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>New Weather App Testing</title>
</head>
<body>
	<cfscript>
		/**
		 * Converts a UNIX epoch time to a ColdFusion date object.
		 * 
		 * @param epoch 	 Epoch time, in seconds. (Required)
		 * @return Returns a date object. 
		 * @author Chris Mellon (mellon@mnr.org) 
		 * @version 1, June 21, 2002 
		 */
		function EpochTimeToDate(epoch) {
		    return DateAdd("s", epoch, "January 1 1970 00:00:00");
		}
	</cfscript>

	<cfoutput>
		#DateFormat(
			EpochTimeToDate( APPLICATION.weatherData.currently.time ),
			'mmmm dd, yyyy'
		)# - #TimeFormat(
			EpochTimeToDate( APPLICATION.weatherData.currently.time ),
			'hh:mm:ss'
		)#
	</cfoutput>

	<cfdump var='#APPLICATION.weatherData#' />
</body>
</html>