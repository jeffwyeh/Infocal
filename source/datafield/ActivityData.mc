using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time.Gregorian as Date;

/* ACTIVE MINUTES */
class ActiveField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function max_val() {
      var activityInfo = ActivityMonitor.getInfo();
      return activityInfo.activeMinutesWeekGoal.toFloat();
   }

   function cur_val() {
      var activityInfo = ActivityMonitor.getInfo();
      return activityInfo.activeMinutesWeek.total.toFloat();
   }

   function max_label(value) {
      return value.format("%d");
   }

   function cur_label(value) {
      return Lang.format("ACT $1$", [value.format("%d")]);
   }

   function bar_data() {
      return true;
   }
}
/* ACTIVE MODERATE MINUTES */
class ActiveModerateField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function max_val() {
      var activityInfo = ActivityMonitor.getInfo();
      return activityInfo.activeMinutesWeekGoal.toFloat();
   }

   function cur_val() {
      var activityInfo = ActivityMonitor.getInfo();
      return activityInfo.activeMinutesWeek.moderate.toFloat();
   }

   function max_label(value) {
      return value.format("%d");
   }

   function cur_label(value) {
      return Lang.format("MACT $1$", [value.format("%d")]);
   }

   function bar_data() {
      return true;
   }
}

/* ACTIVE VIGOROUS MINUTES */
class ActiveVigorousField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function max_val() {
      var activityInfo = ActivityMonitor.getInfo();
      return activityInfo.activeMinutesWeekGoal.toFloat();
  } 

   function cur_val() {
      var activityInfo = ActivityMonitor.getInfo();
      return activityInfo.activeMinutesWeek.vigorous.toFloat();
   }

   function max_label(value) {
      return value.format("%d");
   }

   function cur_label(value) {
      return Lang.format("VACT $1$", [value.format("%d")]);
   }

   function bar_data() {
      return true;
   }
}

/* DISTANCE */
class DistanceField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function max_val() {
      return 300000.0;
   }

   function cur_val() {
      var activityInfo = ActivityMonitor.getInfo();
      var value = activityInfo.distance.toFloat();
      return value;
   }

   function max_label(value) {
      value = value / 1000.0;
      value = value / 100.0; // convert cm to km
      var valKp = App.getApp().toKValue(value);
      return Lang.format("$1$K", [valKp]);
   }

   function cur_label(value) {
      var need_minimal = App.getApp().getProperty("minimal_data");
      var settings = Sys.getDeviceSettings();

      var value2 = value;
      var kilo = value2 / 100000;

      var unit = "Km";
      if (settings.distanceUnits == System.UNIT_METRIC) {
      } else {
         kilo *= 0.621371;
         unit = "Mi";
      }

      if (need_minimal) {
         return Lang.format("$1$ $2$", [kilo.format("%0.1f"), unit]);
      } else {
         var valKp = App.getApp().toKValue(kilo * 1000);
         return Lang.format("DIS $1$$2$", [valKp, unit]);
      }
   }

   function bar_data() {
      return true;
   }
}

/* CALORIES */
class CaloField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function max_val() {
      return 3000.0;
   }

   function cur_val() {
      var activityInfo = ActivityMonitor.getInfo();
      return activityInfo.calories.toFloat();
   }

   function max_label(value) {
      var valKp = App.getApp().toKValue(value);
      return Lang.format("$1$K", [valKp]);
   }

   function cur_label(value) {
      var activeCalories = active_calories(value);
      var need_minimal = App.getApp().getProperty("minimal_data");
      if (need_minimal) {
         return Lang.format("$1$-$2$", [
            value.format("%d"),
            activeCalories.format("%d"),
         ]);
      } else {
         var valKp = App.getApp().toKValue(value);
         return Lang.format("$1$K-$2$", [valKp, activeCalories.format("%d")]);
      }
   }

   function active_calories(value) {
      var now = Time.now();
      var date = Date.info(now, Time.FORMAT_SHORT);

      var profile = UserProfile.getProfile();
      var bonus = profile.gender == UserProfile.GENDER_MALE ? 5.0 : -161.0;
      var age = (date.year - profile.birthYear).toFloat();
      var weight = profile.weight.toFloat() / 1000.0;
      var height = profile.height.toFloat();
      //		var bmr = 0.01*weight + 6.25*height + 5.0*age + bonus; // method 1
      var bmr = -6.1 * age + 7.6 * height + 12.1 * weight + 9.0; // method 2
      var current_segment = (date.hour * 60.0 + date.min).toFloat() / 1440.0;
      //		var nonActiveCalories = 1.604*bmr*current_segment; // method 1
      var nonActiveCalories = 1.003 * bmr * current_segment; // method 2
      var activeCalories = value - nonActiveCalories;
      activeCalories = (activeCalories > 0 ? activeCalories : 0).toNumber();
      return activeCalories;
   }

   function bar_data() {
      return true;
   }
}

/* MOVE BAR */
class MoveField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function min_val() {
      return ActivityMonitor.MOVE_BAR_LEVEL_MIN;
   }

   function max_val() {
      return ActivityMonitor.MOVE_BAR_LEVEL_MAX;
   }

   function cur_val() {
      var info = ActivityMonitor.getInfo();
      var currentBar = info.moveBarLevel.toFloat();
      return currentBar.toFloat();
   }

   function min_label(value) {
      return value.format("%d");
   }

   function max_label(value) {
      return Lang.format("$1$", [value.format("%d")]);
   }

   function cur_label(value) {
      return Lang.format("MOVE $1$", [value.format("%d")]);
   }

   function bar_data() {
      return true;
   }
}

/* STEPS */
class StepField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function max_val() {
      return ActivityMonitor.getInfo().stepGoal.toFloat();
   }

   function cur_val() {
      var currentStep = ActivityMonitor.getInfo().steps;
      return currentStep.toFloat();
   }

   function max_label(value) {
      var valKp = App.getApp().toKValue(value);
      return Lang.format("$1$K", [valKp]);
   }

   function cur_label(value) {
      var need_minimal = App.getApp().getProperty("minimal_data");
      var currentStep = value;
      if (need_minimal) {
         if (currentStep > 999) {
            return currentStep.format("%d");
         } else {
            return Lang.format("STEP $1$", [currentStep.format("%d")]);
         }
      } else {
         var valKp = App.getApp().toKValue(currentStep);
         return Lang.format("STEP $1$K", [valKp]);
      }
   }

   function bar_data() {
      return true;
   }
}

/* DISTANCE FOR WEEK */
class WeekDistanceField extends BaseDataField {
   var days;

   function initialize(id) {
      BaseDataField.initialize(id);
      days = {
         Date.DAY_MONDAY => "MON",
         Date.DAY_TUESDAY => "TUE",
         Date.DAY_WEDNESDAY => "WED",
         Date.DAY_THURSDAY => "THU",
         Date.DAY_FRIDAY => "FRI",
         Date.DAY_SATURDAY => "SAT",
         Date.DAY_SUNDAY => "SUN",
      };
   }

   function min_val() {
      return 50.0;
   }

   function max_val() {
      var datas = _retriveWeekValues();
      return datas[1];
   }

   function cur_val() {
      var datas = _retriveWeekValues();
      return datas[0];
   }

   function cur_label(value) {
      var datas = _retriveWeekValues();
      var total_distance = datas[0];

      var need_minimal = App.getApp().getProperty("minimal_data");
      var settings = Sys.getDeviceSettings();

      var value2 = total_distance;
      var kilo = value2 / 100000;

      var unit = "Km";
      if (settings.distanceUnits == System.UNIT_METRIC) {
      } else {
         kilo *= 0.621371;
         unit = "Mi";
      }

      if (need_minimal) {
         return Lang.format("$1$ $2$", [kilo.format("%0.1f"), unit]);
      } else {
         var valKp = App.getApp().toKValue(kilo * 1000);
         return Lang.format("DIS $1$$2$", [valKp, unit]);
      }
   }

   function day_of_week(activity) {
      var moment = activity.startOfDay;
      var date = Date.info(moment, Time.FORMAT_SHORT);
      return date.day_of_week;
   }

   function today_of_week() {
      var now = Time.now();
      var date = Date.info(now, Time.FORMAT_SHORT);
      return date.day_of_week;
   }

   function _retriveWeekValues() {
      var settings = System.getDeviceSettings();
      var firstDayOfWeek = settings.firstDayOfWeek;

      var activities = [];
      var activityInfo = ActivityMonitor.getInfo();
      activities.add(activityInfo);

      if (today_of_week() != firstDayOfWeek) {
         if (ActivityMonitor has :getHistory) {
            var his = ActivityMonitor.getHistory();
            for (var i = 0; i < his.size(); i++) {
               var activity = his[i];
               activities.add(activity);
               if (day_of_week(activity) == firstDayOfWeek) {
                  break;
               }
            }
         }
      }

      var total = 0.0;
      for (var i = 0; i < activities.size(); i++) {
         total += activities[i].distance;
      }
      return [total, 10.0];
   }

   function bar_data() {
      return true;
   }
}
