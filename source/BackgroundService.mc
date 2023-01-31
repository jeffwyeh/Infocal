using Toybox.Background as Bg;
using Toybox.System as Sys;
using Toybox.Communications as Comms;
using Toybox.Application as App;

(:background)
class BackgroundService extends Sys.ServiceDelegate {
   (:background_method)
   function initialize() {
      Sys.ServiceDelegate.initialize();
   }

   // Read pending web requests, and call appropriate web request function.
   // This function determines priority of web requests, if multiple are pending.
   // Pending web request flag will be cleared only once the background data has been successfully received.
   (:background_method)
   function onTemporalEvent() {
      var pendingWebRequests = App.getApp().getProperty("PendingWebRequests");
      if (pendingWebRequests != null) {
         if (pendingWebRequests["OpenWeatherMapCurrent"] != null) {
            var api_key = App.getApp().getProperty("openweathermap_api");
            if (api_key.length() == 0) {
               api_key = "333d6a4283794b870f5c717cc48890b5"; // default apikey
            }
            makeWebRequest(
               "https://api.openweathermap.org/data/2.5/weather",
               {
                  "lat" => App.getApp().getProperty("LastLocationLat"),
                  "lon" => App.getApp().getProperty("LastLocationLng"),
                  "appid" => api_key,
                  "units" => "metric", // Celcius.
               },
               method(:onReceiveOpenWeatherMapCurrent)
            );
         }
      }
   }

   (:background_method)
   function onReceiveOpenWeatherMapCurrent(responseCode, data) {
      var result;

      // Useful data only available if result was successful.
      // Filter and flatten data response for data that we actually need.
      // Reduces runtime memory spike in main app.
      if (responseCode == 200) {
         result = {
            "cod" => data["cod"],
            "lat" => data["coord"]["lat"],
            "lon" => data["coord"]["lon"],
            "dt" => data["dt"],
            "temp" => data["main"]["temp"],
            "temp_min" => data["main"]["temp_min"],
            "temp_max" => data["main"]["temp_max"],
            "humidity" => data["main"]["humidity"],
            "wind_speed" => data["wind"]["speed"],
            "wind_direct" => data["wind"]["deg"],
            "icon" => data["weather"][0]["icon"],
            "des" => data["weather"][0]["main"],
         };

         // HTTP error: do not save.
      } else {
         result = {
            "httpError" => responseCode,
         };
      }

      Bg.exit({
         "OpenWeatherMapCurrent" => result,
      });
   }

   (:background_method)
   function makeWebRequest(url, params, callback) {
      var options = {
         :method => Comms.HTTP_REQUEST_METHOD_GET,
         :headers => {
            "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
         },
         :responseType => Comms.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      };

      Comms.makeWebRequest(url, params, options, callback);
   }
}
