using Toybox.Activity as Activity;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Application as App;
using Toybox.System as Sys;

/* BATTERY */
class BatteryField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function min_val() {
      return 0.0;
   }

   function max_val() {
      return 100.0;
   }

   function cur_val() {
      return Sys.getSystemStats().battery;
   }

   function min_label(value) {
      return "b";
   }

   function max_label(value) {
      return "P";
   }

   function cur_label(value) {
      var battery_format = App.getApp().getProperty("battery_format");
      var hour_consumption = last_hour_consumption;
      if (hour_consumption <= 0) {
         var consumption_history =
            App.getApp().getProperty("consumption_history");
         if (consumption_history != null) {
            var total = 0.0;
            for (var i = 0; i < consumption_history.size(); i++) {
               // Code to do in a loop
               total += consumption_history[i];
            }
            hour_consumption = total / consumption_history.size();
         } else {
            var hour_consumption_saved = App.getApp().getProperty(
               "last_hour_consumption"
            );
            if (hour_consumption_saved != null) {
               hour_consumption = hour_consumption_saved;
            }
         }
      }
      hour_consumption = hour_consumption.toFloat();

      if (battery_format == 0 || hour_consumption == -1) {
         // show percent
         return Lang.format("BAT $1$%", [Math.round(value).format("%d")]);
      } else {
         if (hour_consumption == 0) {
            return Lang.format("$1$ DAYS", [99]);
         }
         var hour_left = value / (hour_consumption * 1.0);
         var day_left = hour_left / 24.0;
         return Lang.format("$1$ DAYS", [day_left.format("%0.1f")]);
      }
   }

   function bar_data() {
      return true;
   }
}

/* HEART RATE */
class HRField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function min_val() {
      return 50.0;
   }

   function max_val() {
      return 120.0;
   }

   function cur_val() {
      var heartRate = _retrieveHeartrate();
      return heartRate.toFloat();
   }

   function min_label(value) {
      return value.format("%d");
   }

   function max_label(value) {
      return value.format("%d");
   }

   function cur_label(value) {
      var heartRate = value;
      if (heartRate <= 1) {
         return "HR --";
      }
      return Lang.format("HR $1$", [heartRate.format("%d")]);
   }

   function bar_data() {
      return true;
   }
}

function doesDeviceSupportHeartrate() {
   return ActivityMonitor has :INVALID_HR_SAMPLE;
}

function _retrieveHeartrate() {
   var currentHeartrate = 0.0;
   var activityInfo = Activity.getActivityInfo();
   var sample = activityInfo.currentHeartRate;
   if (sample != null) {
      currentHeartrate = sample;
   } else if (ActivityMonitor has :getHeartRateHistory) {
      sample = ActivityMonitor.getHeartRateHistory(
         1,
         /* newestFirst */ true
      ).next();
      if (
         sample != null &&
         sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE
      ) {
         currentHeartrate = sample.heartRate;
      }
   }
   return currentHeartrate.toFloat();
}

/* BODY BATTERY */
class BodyBatteryField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function min_val() {
      return 0.0;
   }

   function max_val() {
      return 100.0;
   }

   function cur_val() {
      var bodyBattery = _retrieveBodyBattery();
      return bodyBattery.toFloat();
   }

   function min_label(value) {
      return value.format("%d");
   }

   function max_label(value) {
      return value.format("%d");
   }

   function cur_label(value) {
      var bodyBattery = value;
      if (bodyBattery <= 1) {
         return "BODY --";
      }
      return Lang.format("BODY $1$", [bodyBattery.format("%d")]);
   }

   function bar_data() {
      return true;
   }
}

function _retrieveBodyBattery() {
   var currentBodyBattery = 0.0;
   if (
      Toybox has :SensorHistory &&
      Toybox.SensorHistory has :getBodyBatteryHistory
   ) {
      var sample = Toybox.SensorHistory.getBodyBatteryHistory({
         :period => 1,
      }).next();
      if (sample != null && sample.data != null) {
         currentBodyBattery = sample.data;
      }
   }
   return currentBodyBattery.toFloat();
}

/* STRESS */
class StressField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function min_val() {
      return 0.0;
   }

   function max_val() {
      return 100.0;
   }

   function cur_val() {
      var stress = _retrieveStress();
      return stress.toFloat();
   }

   function min_label(value) {
      return value.format("%d");
   }

   function max_label(value) {
      return value.format("%d");
   }

   function cur_label(value) {
      var stress = value;
      if (stress <= 1) {
         return "STRESS --";
      }
      return Lang.format("STRESS $1$", [stress.format("%d")]);
   }

   function bar_data() {
      return true;
   }
}

function _retrieveStress() {
   var currentStress = 0.0;
   if (
      Toybox has :SensorHistory &&
      Toybox.SensorHistory has :getStressHistory
   ) {
      var sample = Toybox.SensorHistory.getStressHistory({
         :period => 1,
      }).next();
      if (sample != null && sample.data != null) {
         currentStress = sample.data;
      }
   }
   return currentStress.toFloat();
}

/* BODY BATTERY/STRESS COMBINED */
class BodyBatteryStressField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function min_val() {
      return 0.0;
   }

   function max_val() {
      return 100.0;
   }

   function cur_val() {
      return 0.0;
   }

   function min_label(value) {
      return value.format("%d");
   }

   function max_label(value) {
      return value.format("%d");
   }

   function cur_label(value) {
      var bodyBattery = _retrieveBodyBattery();
      var bodyBatteryString = "--";
      if (bodyBattery > 1) {
         bodyBatteryString = bodyBattery.format("%d");
      }
      var stress = _retrieveStress();
      var stressString = "--";
      if (stress > 1) {
         stressString = stress.format("%d");
      }
      return Lang.format("B $1$ S $2$", [bodyBatteryString, stressString]);
   }

   function bar_data() {
      return false;
   }
}

/* ALTITUDE */
class AltitudeField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var need_minimal = App.getApp().getProperty("minimal_data");
      value = 0;
      // #67 Try to retrieve altitude from current activity, before falling back on elevation history.
      // Note that Activity::Info.altitude is supported by CIQ 1.x, but elevation history only on select CIQ 2.x
      // devices.
      var settings = Sys.getDeviceSettings();
      var activityInfo = Activity.getActivityInfo();
      var altitude = activityInfo.altitude;
      if (
         altitude == null &&
         Toybox has :SensorHistory &&
         Toybox.SensorHistory has :getElevationHistory
      ) {
         var sample = SensorHistory.getElevationHistory({
            :period => 1,
            :order => SensorHistory.ORDER_NEWEST_FIRST,
         }).next();
         if (sample != null && sample.data != null) {
            altitude = sample.data;
         }
      }
      if (altitude != null) {
         var unit = "";
         // Metres (no conversion necessary).
         if (settings.elevationUnits == System.UNIT_METRIC) {
            unit = "m";
            // Feet.
         } else {
            altitude *= /* FT_PER_M */ 3.28084;
            unit = "ft";
         }

         value = altitude.format("%d");
         value += unit;
         if (need_minimal) {
            return value;
         } else {
            var temp = Lang.format("ALTI $1$", [value]);
            if (temp.length() > 10) {
               return Lang.format("$1$", [value]);
            }
            return temp;
         }
      } else {
         if (need_minimal) {
            return "--";
         } else {
            return "ALTI --";
         }
      }
   }
}

/* ON DEVICE TEMPERATURE */
class TemparatureField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var need_minimal = App.getApp().getProperty("minimal_data");
      value = 0;
      var settings = Sys.getDeviceSettings();
      if (
         Toybox has :SensorHistory &&
         Toybox.SensorHistory has :getTemperatureHistory
      ) {
         var sample = SensorHistory.getTemperatureHistory(null).next();
         if (sample != null && sample.data != null) {
            var temperature = sample.data;
            if (settings.temperatureUnits == System.UNIT_STATUTE) {
               temperature = temperature * (9.0 / 5) + 32; // Convert to Farenheit: ensure floating point division.
            }
            value = temperature.format("%d") + "°";
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
      } else {
         if (need_minimal) {
            return "--";
         } else {
            return "TEMP --";
         }
      }
   }
}
/* ALARM */
class AlarmField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var settings = Sys.getDeviceSettings();
      value = settings.alarmCount;
      return Lang.format("ALAR $1$", [value.format("%d")]);
   }
}

/* FLOORS CLIMBED */
class FloorField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function max_val() {
      var activityInfo = ActivityMonitor.getInfo();
      if (activityInfo has :floorsClimbedGoal) {
         return activityInfo.floorsClimbedGoal.toFloat();
      } else {
         return 1.0;
      }
   }

   function cur_val() {
      var activityInfo = ActivityMonitor.getInfo();
      if (activityInfo has :floorsClimbed) {
         return activityInfo.floorsClimbed.toFloat();
      } else {
         return 0.0;
      }
   }

   function max_label(value) {
      return value.format("%d");
   }

   function cur_label(value) {
      if (value == null) {
         return "FLOOR --";
      }
      return Lang.format("FLOOR $1$", [value.format("%d")]);
   }

   function bar_data() {
      return true;
   }
}

/* BAROMETER */
class BarometerField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_val() {
      var presure_data = _retrieveBarometer();
      return presure_data;
   }

   function cur_label(value) {
      var value1 = value[0];
      var value2 = value[1];
      if (value1 == null) {
         return "BARO --";
      } else {
         var hector_pascal = value1 / 100.0;

         var unit = App.getApp().getProperty("barometer_unit");
         if (unit == 1) {
            // convert to inHg
            hector_pascal = hector_pascal * 0.0295301;
         }
         var signal = "";
         if (value2 == 1) {
            signal = "+";
         } else if (value2 == -1) {
            signal = "-";
         }

         if (unit == 1) {
            return Lang.format("BAR $1$$2$", [
               hector_pascal.format("%0.2f"),
               signal,
            ]);
         }
         return Lang.format("BAR $1$$2$", [hector_pascal.format("%d"), signal]);
      }
   }

   // Create a method to get the SensorHistoryIterator object
   function _getIterator() {
      // Check device for SensorHistory compatibility
      if (
         Toybox has :SensorHistory &&
         Toybox.SensorHistory has :getPressureHistory
      ) {
         return Toybox.SensorHistory.getPressureHistory({});
      }
      return null;
   }

   // Create a method to get the SensorHistoryIterator object
   function _getIteratorDurate(hour) {
      // Check device for SensorHistory compatibility
      if (
         Toybox has :SensorHistory &&
         Toybox.SensorHistory has :getPressureHistory
      ) {
         var duration = new Time.Duration(hour * 3600);
         return Toybox.SensorHistory.getPressureHistory({
            "period" => duration,
            "order" => SensorHistory.ORDER_OLDEST_FIRST,
         });
      }
      return null;
   }

   function _retrieveBarometer() {
      var trend_iter = _getIteratorDurate(3); // 3 hour
      var trending = null;
      if (trend_iter != null) {
         // get 5 sample
         var sample = null;
         var num = 0.0;
         for (var i = 0; i < 5; i += 1) {
            sample = trend_iter.next();
            if (sample != null && sample has :data) {
               var d = sample.data;
               if (d != null) {
                  if (trending == null) {
                     trending = d;
                     num += 1;
                  } else {
                     trending += d;
                     num += 1;
                  }
               }
            }
         }
         if (trending != null) {
            trending /= num;
         }
      }
      var iter = _getIterator();
      // Print out the next entry in the iterator
      if (iter != null) {
         var sample = iter.next();
         if (sample != null && sample has :data) {
            var d = sample.data;
            var c = 0;
            if (trending != null && d != null) {
               c = trending > d ? -1 : 1;
            }
            return [d, c];
         }
      }
      return [null, 0];
   }
}
