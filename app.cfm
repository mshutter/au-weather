<!--- For easiest reading, expand window until this comment occupies one line -------------------------------------->

<style>
  /* These classes will be dynamically applied to hide visually-hidden entities from screen readers as well */
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
   * @param epoch    Epoch time, in seconds. (Required)
   * @return Returns a date object. 
   * @author Chris Mellon (mellon@mnr.org) - Revised by Michael Shutter (mshutter.dev@gmail.com)
   * @version 1, June 21, 2002 
   */
  function EpochTimeToDate(epoch) {
      // Convert to ColdFusion object
      cfDateTime = DateAdd("s", epoch, "January 1 1970 00:00:00");

      // Convert GMT to EST (correct timezone difference)
      return DateAdd('h', -4, cfDateTime);
  }
</cfscript>



<!--- WeatherIcon class name references, based on API icon value --->
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

<!--- Uncomment for debugging
  <cfdump var='#APPLICATION.weatherData#' />
--->

<!--- Bring current and daily weather data from application scope to local scope ---> 
<cfset current = APPLICATION.weatherData.currently />
<cfset daily   = APPLICATION.weatherData.daily.data />



<div class="wthr-container">

  <!---
    Current Weather (top and middle sections)
  --->
  
  <div class="wthr-row">
  <div class="wthr-current">
  <cfoutput>

    <!--- Heading (with day and time) --->
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


    <!--- Current weather overview (middle section, left column) --->
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

    
    <!--- Current weather details (middle section, right column) --->
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
    Daily forecast thumbnails (lower section)
  --->

  <div class='wthr-row'>
  <div class='wthr-daily'>
  <cfoutput>

    <!--- Forecast information for next 6 days --->
    <div class="wthr-table">
    <cfloop from='1' to='6' index='i'>

      <!--- Thumbnail template for each day --->
      <div class='wthr-day-thumb' id='wthr-day-thumb-#i#' onclick='showWeatherDetails(#i#)'>
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
    Daily forecast details (drop-down section)
  --->

  <div class="wthr-row">
  <cfoutput>
  <cfloop from='1' to='6' index='i'>

    <!--- Note:
      div.wthr-daily-details is a container for daily weather detail information, but in order for
      jQuery's visual sliding effect to work, a div.wthr-slide-handle must be added within each container.

      Before user selects a thumbnail, all containers and slide handles will be hidden. Once the
      user selects a thumbnail, all slide handles will slide down but only the selected HTML
      container will become visible (giving the appearance of only one pane sliding down).

      While the details pane is open, all slide handles will stay open while visibility will
      shift between div.daily-weather-details containers according to user selection.

      When a user closes the details pane (by re-clicking currently selected thumbnail) all slide
      handles will slide up, so the visual slide down effect will work when this entire process
      is repeated.
    --->

    <div class="wthr-daily-details" id='wthr-details-#i#' style='display:none;'>
    <div class="wthr-slide-handle" style='display:none;'>
    
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

    </div> <!-- .wthr-slide-handle -->
    </div> <!-- .wthr-daily-details -->

  </cfloop>
  </cfoutput>
  </div> <!-- .wthr-row -->

</div> <!-- .wthr-container -->

<script>
    
  /**
   * Handles visual display of the drop-down daily weather details pane,
   * as well as all associated HTML manipulation that goes along with it.
   *
   * @param    id -> Integer representing which thumbnail has been selected (1 - 6)
   * @return   false (void)
   * @author   Michael Shutter (mshutter.dev@gmail.com)
   * @version  1.0 (October 7, 2015)
   */

  function showWeatherDetails (id) {

    if ( $('#wthr-day-thumb-'+id).attr('data-selected') ) {      /* If currently-selected thumb is clicked */
      $('.wthr-slide-handle').slideUp({                          // slide details pane up,
          duration: 200,
          complete: function () {
            $('.wthr-daily-details, .wthr-slide-handle').hide(); // hide all details element,
          }
        });
      $('.wthr-day-thumb').removeAttr('data-selected');          // and 'deselect' all thumbnails.


    } else if ( $('.wthr-day-thumb[data-selected]').length ) {   /* If new thumb is clicked (details pane open): */
      $('.wthr-daily-details').hide();                           // hide all details elements,
      $('.wthr-day-thumb').removeAttr('data-selected');          // deselect all thumbnails,

      $('#wthr-day-thumb-'+id).attr('data-selected', 'true');    // select current thumbnail,
      $('#wthr-details-'+id).show();                             // and show current details element.


    } else {                                                     /* If new thumb is clicked (details pane hidden): */
      $('#wthr-day-thumb-'+id).attr('data-selected', 'true');    // select current thumbnail,
      $('#wthr-details-'+id).show();                             // show current details element,
      $('.wthr-slide-handle').slideDown({ duration: 200 });      // and slide details pane in.
    }

    return false;
  }
</script>