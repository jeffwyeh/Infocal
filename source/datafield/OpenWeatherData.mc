using Toybox.Application as App;
using Toybox.System as Sys;

/* TEMPERATURE HIGH/LOW */
class TemparatureHLField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      // WEATHER
      var need_minimal = App.getApp().getProperty("minimal_data");
      var weather_data = App.getApp().getProperty("OpenWeatherMapCurrent");
      if (weather_data != null) {
         var settings = Sys.getDeviceSettings();
         var temp_min = weather_data["temp_min"];
         var temp_max = weather_data["temp_max"];
         var unit = "°C";
         if (settings.temperatureUnits == System.UNIT_STATUTE) {
            temp_min = temp_min * (9.0 / 5) + 32; // Convert to Farenheit: ensure floating point division.
            temp_max = temp_max * (9.0 / 5) + 32; // Convert to Farenheit: ensure floating point division.
            unit = "°F";
         }
         if (need_minimal) {
            return Lang.format("$1$ $2$", [
               temp_max.format("%d"),
               temp_min.format("%d"),
            ]);
         } else {
            return Lang.format("H $1$ L $2$", [
               temp_max.format("%d"),
               temp_min.format("%d"),
            ]);
         }
      } else {
         if (need_minimal) {
            return "--";
         } else {
            return "H - L -";
         }
      }
   }
}

/* TEMPERATURE OUTSIDE */
class TemparatureOutField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      // WEATHER
      var need_minimal = App.getApp().getProperty("minimal_data");
      var weather_data = App.getApp().getProperty("OpenWeatherMapCurrent");
      if (weather_data != null) {
         var settings = Sys.getDeviceSettings();
         var temp = weather_data["temp"];
         var unit = "°C";
         if (settings.temperatureUnits == System.UNIT_STATUTE) {
            temp = temp * (9.0 / 5) + 32; // Convert to Farenheit: ensure floating point division.
            unit = "°F";
         }
         value = temp.format("%d") + unit;

         if (need_minimal) {
            return value;
         } else {
            return Lang.format("TEMP $1$", [value]);
         }
      } else {
         if (need_minimal) {
            return "--";
         } else {
            return "TEMP --";
         }
      }
   }
}


/* WEATHER */
class WeatherField extends BaseDataField {
   var weather_icon_mapper;
   function initialize(id) {
      BaseDataField.initialize(id);

      weather_icon_mapper = {
         "01d" => "",
         "02d" => "",
         "03d" => "",
         "04d" => "",
         "09d" => "",
         "10d" => "",
         "11d" => "",
         "13d" => "",
         "50d" => "",

         "01n" => "",
         "02n" => "",
         "03n" => "",
         "04n" => "",
         "09n" => "",
         "10n" => "",
         "11n" => "",
         "13n" => "",
         "50n" => "",
      };
   }

   function cur_icon() {
      var weather_data = App.getApp().getProperty("OpenWeatherMapCurrent");
      if (weather_data != null) {
         return weather_icon_mapper[weather_data["icon"]];
      }
      return null;
   }

   function cur_label(value) {
      // WEATHER
      var need_minimal = App.getApp().getProperty("minimal_data");
      var weather_data = App.getApp().getProperty("OpenWeatherMapCurrent");
      if (weather_data != null) {
         var settings = Sys.getDeviceSettings();
         var temp = weather_data["temp"];
         var unit = "°C";
         if (settings.temperatureUnits == System.UNIT_STATUTE) {
            temp = temp * (9.0 / 5) + 32; // Convert to Farenheit: ensure floating point division.
            unit = "°F";
         }
         value = temp.format("%d") + unit;

         var description = weather_data.get("des");
         if (description != null) {
            return description + " " + value;
         }
      }
      return "--";
   }
}

/* WIND */
class WindField extends BaseDataField {
   var wind_direction_mapper;

   function initialize(id) {
      BaseDataField.initialize(id);
      wind_direction_mapper = [
         "N",
         "NNE",
         "NE",
         "ENE",
         "E",
         "ESE",
         "SE",
         "SSE",
         "S",
         "SSW",
         "SW",
         "WSW",
         "W",
         "WNW",
         "NW",
         "NNW",
      ];
   }

   function cur_label(value) {
      var need_minimal = App.getApp().getProperty("minimal_data");
      var weather_data = App.getApp().getProperty("OpenWeatherMapCurrent");
      if (weather_data != null) {
         var settings = Sys.getDeviceSettings();
         var speed = weather_data["wind_speed"] * 3.6; // kph
         var direct = weather_data["wind_direct"];

         var direct_corrected = direct + 11.25; // move degrees to int spaces (North from 348.75-11.25 to 360(min)-22.5(max))
         direct_corrected =
            direct_corrected < 360 ? direct_corrected : direct_corrected - 360; // move North from 360-371.25 back to 0-11.25 (final result is North 0(min)-22.5(max))
         var direct_idx = (direct_corrected / 22.5).toNumber(); // now calculate direction array position: int([0-359.99]/22.5) will result in 0-15 (correct array positions)

         var directLabel = wind_direction_mapper[direct_idx];
         var unit = "k";
         if (settings.distanceUnits == System.UNIT_STATUTE) {
            speed *= 0.621371;
            unit = "m";
         }
         return directLabel + " " + speed.format("%0.1f") + unit;
      }
      return "--";
   }
}
