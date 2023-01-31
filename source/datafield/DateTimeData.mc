using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time.Gregorian as Date;

/* AM/PM INDICATOR */
class AMPMField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var clockTime = Sys.getClockTime();
      var hour = clockTime.hour;
      if (hour >= 12) {
         return "pm";
      } else {
         return "am";
      }
   }
}

/* TIME */
class TimeField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      return getTimeString();
   }

   function getTimeString() {
      var currentSettings = System.getDeviceSettings();
      var clockTime = Sys.getClockTime();
      var hour = clockTime.hour;
      var minute = clockTime.min;
      var mark = "";
      if (!currentSettings.is24Hour) {
         if (hour >= 12) {
            mark = "pm";
         } else {
            mark = "am";
         }
         hour = hour % 12;
         hour = hour == 0 ? 12 : hour;
      }
      return Lang.format("$1$:$2$ $3$", [hour, minute.format("%02d"), mark]);
   }
}

/* DATE */
class DateField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      return Application.getApp().getFormattedDate();
   }
}

/* WEEK COUNT */
class WeekCountField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function julian_day(year, month, day) {
      var a = (14 - month) / 12;
      var y = year + 4800 - a;
      var m = month + 12 * a - 3;
      return (
         day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
      );
   }

   function is_leap_year(year) {
      if (year % 4 != 0) {
         return false;
      } else if (year % 100 != 0) {
         return true;
      } else if (year % 400 == 0) {
         return true;
      }
      return false;
   }

   function iso_week_number(year, month, day) {
      var first_day_of_year = julian_day(year, 1, 1);
      var given_day_of_year = julian_day(year, month, day);

      var day_of_week = (first_day_of_year + 3) % 7; // days past thursday
      var week_of_year =
         (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;

      // week is at end of this year or the beginning of next year
      if (week_of_year == 53) {
         if (day_of_week == 6) {
            return week_of_year;
         } else if (day_of_week == 5 && is_leap_year(year)) {
            return week_of_year;
         } else {
            return 1;
         }
      } // week is in previous year, try again under that year
      else if (week_of_year == 0) {
         first_day_of_year = julian_day(year - 1, 1, 1);

         day_of_week = (first_day_of_year + 3) % 7;

         return (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;
      } // any old week of the year
      else {
         return week_of_year;
      }
   }

   function cur_label(value) {
      var date = Date.info(Time.now(), Time.FORMAT_SHORT);
      var week_num = iso_week_number(date.year, date.month, date.day);
      return Lang.format("WEEK $1$", [week_num]);
   }
}

/* COUNTDOWN */
class CountdownField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var set_end_date = new Time.Moment(
         App.getApp().getProperty("countdown_date")
      );
      var now_d = new Time.Moment(Time.today().value());
      var dif_e_n = -now_d.compare(set_end_date) / 86400;
      if (dif_e_n > 1 || dif_e_n < -1) {
         return Lang.format("$1$ days", [dif_e_n.toString()]);
      } else {
         return Lang.format("$1$ day", [dif_e_n.toString()]);
      }
   }
}

/* SECONDARY TIME */
class TimeSecondaryField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var currentSettings = System.getDeviceSettings();
      var clockTime = Sys.getClockTime();
      var to_utc_second = clockTime.timeZoneOffset;

      var target = App.getApp().getProperty("utc_timezone");
      var shift_val = App.getApp().getProperty("utc_shift") ? 0.5 : 0.0;
      var secondary_zone_delta = (target + shift_val) * 3600 - to_utc_second;

      var now = Time.now();
      var now_target_zone_delta = new Time.Duration(secondary_zone_delta.toNumber());
      var now_target_zone = now.add(now_target_zone_delta);
      var target_zone = Date.info(now_target_zone, Time.FORMAT_SHORT);

      var hour = target_zone.hour;
      var minute = target_zone.min;
      var mark = "";
      if (!currentSettings.is24Hour) {
         if (hour >= 12) {
            mark = "pm";
         } else {
            mark = "am";
         }
         hour = hour % 12;
         hour = hour == 0 ? 12 : hour;
      }
      return Lang.format("$1$:$2$ $3$", [hour, minute.format("%02d"), mark]);
   }
}
