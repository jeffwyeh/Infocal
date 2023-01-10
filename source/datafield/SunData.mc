using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time.Gregorian as Date;

/* SUNRISE/SUNSET */
class SunField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      if (gLocationLat != null) {
         value = "";
         var nextSunEvent = 0;
         var isSunriseNext = false;
         var now = Date.info(Time.now(), Time.FORMAT_SHORT);

         // Convert to same format as sunTimes, for easier comparison. Add a minute, so that e.g. if sun rises at
         // 07:38:17, then 07:38 is already consided daytime (seconds not shown to user).
         now = now.hour + now.min / 60.0;

         // Get today's sunrise/sunset times in current time zone.
         var sunTimes = getSunTimes(
            gLocationLat,
            gLocationLng,
            null,
            /* tomorrow */ false
         );

         // If sunrise/sunset happens today.
         var sunriseSunsetToday = sunTimes[0] != null && sunTimes[1] != null;
         if (sunriseSunsetToday) {
            // Before sunrise today: today's sunrise is next.
            if (now < sunTimes[0]) {
               nextSunEvent = sunTimes[0];
               isSunriseNext = true;

               // After sunrise today, before sunset today: today's sunset is next.
            } else if (now < sunTimes[1]) {
               nextSunEvent = sunTimes[1];

               // After sunset today: tomorrow's sunrise (if any) is next.
            } else {
               sunTimes = getSunTimes(
                  gLocationLat,
                  gLocationLng,
                  null,
                  /* tomorrow */ true
               );
               nextSunEvent = sunTimes[0];
               isSunriseNext = true;
            }
         }

         // Sun never rises/sets today.
         if (!sunriseSunsetToday) {
            // Sun never rises: sunrise is next, but more than a day from now.
            if (sunTimes[0] == null) {
               isSunriseNext = true;
            }
            return "SUN --";
            // We have a sunrise/sunset time.
         } else {
            var need_minimal = App.getApp().getProperty("minimal_data");
            var hour = Math.floor(nextSunEvent).toLong() % 24;
            var min = Math.floor(
               (nextSunEvent - Math.floor(nextSunEvent)) * 60
            ); // Math.floor(fractional_part * 60)
            var ftime = getFormattedTime(hour, min);
            //				var timestr = ftime[:hour] + ":" + ftime[:min] + ftime[:amPm];
            var timestr = ftime[:hour] + ":" + ftime[:min];

            var riseicon = isSunriseNext ? "RISE" : "SET";
            if (need_minimal) {
               riseicon = isSunriseNext ? "RI" : "SE";
            }
            return Lang.format("$1$ $2$", [riseicon, timestr]);
         }

         // Waiting for location.
      } else {
         return "SUN --";
      }
   }

   /**
    * With thanks to ruiokada. Adapted, then translated to Monkey C, from:
    * https://gist.github.com/ruiokada/b28076d4911820ddcbbc
    *
    * Calculates sunrise and sunset in local time given latitude, longitude, and tz.
    *
    * Equations taken from:
    * https://en.wikipedia.org/wiki/Julian_day#Converting_Julian_or_Gregorian_calendar_date_to_Julian_Day_Number
    * https://en.wikipedia.org/wiki/Sunrise_equation#Complete_calculation_on_Earth
    *
    * @method getSunTimes
    * @param {Float} lat Latitude of location (South is negative)
    * @param {Float} lng Longitude of location (West is negative)
    * @param {Integer || null} tz Timezone hour offset. e.g. Pacific/Los Angeles is -8 (Specify null for system timezone)
    * @param {Boolean} tomorrow Calculate tomorrow's sunrise and sunset, instead of today's.
    * @return {Array} Returns array of length 2 with sunrise and sunset as floats.
    *                 Returns array with [null, -1] if the sun never rises, and [-1, null] if the sun never sets.
    */
   function getSunTimes(lat, lng, tz, tomorrow) {
      // Use double precision where possible, as floating point errors can affect result by minutes.
      lat = lat.toDouble();
      lng = lng.toDouble();

      var now = Time.now();
      if (tomorrow) {
         now = now.add(new Time.Duration(24 * 60 * 60));
      }
      var d = Date.info(Time.now(), Time.FORMAT_SHORT);
      var rad = Math.PI / 180.0d;
      var deg = 180.0d / Math.PI;

      // Calculate Julian date from Gregorian.
      var a = Math.floor((14 - d.month) / 12);
      var y = d.year + 4800 - a;
      var m = d.month + 12 * a - 3;
      var jDate =
         d.day +
         Math.floor((153 * m + 2) / 5) +
         365 * y +
         Math.floor(y / 4) -
         Math.floor(y / 100) +
         Math.floor(y / 400) -
         32045;

      // Number of days since Jan 1st, 2000 12:00.
      var n = jDate - 2451545.0d + 0.0008d;

      // Mean solar noon.
      var jStar = n - lng / 360.0d;

      // Solar mean anomaly.
      var M = 357.5291d + 0.98560028d * jStar;
      var MFloor = Math.floor(M);
      var MFrac = M - MFloor;
      M = MFloor.toLong() % 360;
      M += MFrac;

      // Equation of the centre.
      var C =
         1.9148d * Math.sin(M * rad) +
         0.02d * Math.sin(2 * M * rad) +
         0.0003d * Math.sin(3 * M * rad);

      // Ecliptic longitude.
      var lambda = M + C + 180 + 102.9372d;
      var lambdaFloor = Math.floor(lambda);
      var lambdaFrac = lambda - lambdaFloor;
      lambda = lambdaFloor.toLong() % 360;
      lambda += lambdaFrac;

      // Solar transit.
      var jTransit =
         2451545.5d +
         jStar +
         0.0053d * Math.sin(M * rad) -
         0.0069d * Math.sin(2 * lambda * rad);

      // Declination of the sun.
      var delta = Math.asin(Math.sin(lambda * rad) * Math.sin(23.44d * rad));

      // Hour angle.
      var cosOmega =
         (Math.sin(-0.83d * rad) - Math.sin(lat * rad) * Math.sin(delta)) /
         (Math.cos(lat * rad) * Math.cos(delta));

      // Sun never rises.
      if (cosOmega > 1) {
         return [null, -1];
      }

      // Sun never sets.
      if (cosOmega < -1) {
         return [-1, null];
      }

      // Calculate times from omega.
      var omega = Math.acos(cosOmega) * deg;
      var jSet = jTransit + omega / 360.0;
      var jRise = jTransit - omega / 360.0;
      var deltaJSet = jSet - jDate;
      var deltaJRise = jRise - jDate;

      var tzOffset = tz == null ? Sys.getClockTime().timeZoneOffset / 3600 : tz;
      return [
         /* localRise */ deltaJRise * 24 + tzOffset,
         /* localSet */ deltaJSet * 24 + tzOffset,
      ];
   }

   // Return a formatted time dictionary that respects is24Hour and HideHoursLeadingZero settings.
   // - hour: 0-23.
   // - min:  0-59.
   function getFormattedTime(hour, min) {
      var amPm = "";

      if (!Sys.getDeviceSettings().is24Hour) {
         // #6 Ensure noon is shown as PM.
         var isPm = hour >= 12;
         if (isPm) {
            // But ensure noon is shown as 12, not 00.
            if (hour > 12) {
               hour = hour - 12;
            }
            amPm = "p";
         } else {
            // #27 Ensure midnight is shown as 12, not 00.
            if (hour == 0) {
               hour = 12;
            }
            amPm = "a";
         }
      }

      // #10 If in 12-hour mode with Hide Hours Leading Zero set, hide leading zero. Otherwise, show leading zero.
      // #69 Setting now applies to both 12- and 24-hour modes.
      hour = hour.format("%2d");

      return {
         :hour => hour,
         :min => min.format("%02d"),
         :amPm => amPm,
      };
   }
}
