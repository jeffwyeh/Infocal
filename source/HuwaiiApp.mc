using Toybox.Application;
using Toybox.Activity as Activity;
using Toybox.System as Sys;
using Toybox.Background as Bg;
using Toybox.WatchUi as Ui;
using Toybox.Time;
using Toybox.Math;
using Toybox.Time.Gregorian as Date;

var centerX;
var centerY;

function degreesToRadians(degrees) {
   return (degrees * Math.PI) / 180;
}

function radiansToDegrees(radians) {
   return (radians * 180) / Math.PI;
}

function convertCoorX(radians, radius) {
   return centerX + radius * Math.cos(radians);
}

function convertCoorY(radians, radius) {
   return centerY + radius * Math.sin(radians);
}

(:background)
class HuwaiiApp extends Application.AppBase {
   var mView;
   var days;
   var months;

   function initialize() {
      AppBase.initialize();
      days = {
         Date.DAY_MONDAY => "MON",
         Date.DAY_TUESDAY => "TUE",
         Date.DAY_WEDNESDAY => "WED",
         Date.DAY_THURSDAY => "THU",
         Date.DAY_FRIDAY => "FRI",
         Date.DAY_SATURDAY => "SAT",
         Date.DAY_SUNDAY => "SUN",
      };
      months = {
         Date.MONTH_JANUARY => "JAN",
         Date.MONTH_FEBRUARY => "FEB",
         Date.MONTH_MARCH => "MAR",
         Date.MONTH_APRIL => "APR",
         Date.MONTH_MAY => "MAY",
         Date.MONTH_JUNE => "JUN",
         Date.MONTH_JULY => "JUL",
         Date.MONTH_AUGUST => "AUG",
         Date.MONTH_SEPTEMBER => "SEP",
         Date.MONTH_OCTOBER => "OCT",
         Date.MONTH_NOVEMBER => "NOV",
         Date.MONTH_DECEMBER => "DEC",
      };
   }

   // onStart() is called on application start up
   function onStart(state) {
      //    	// var clockTime = Sys.getClockTime();
      //    	// Sys.println("" + clockTime.min + ":" + clockTime.sec);
   }

   // onStop() is called when your application is exiting
   function onStop(state) {
      //    	// var clockTime = Sys.getClockTime();
      //    	// Sys.println("" + clockTime.min + ":" + clockTime.sec);
   }

   // Return the initial view of your application here
   function getInitialView() {
      mView = new HuwaiiView();
      return [mView];
   }

   function getView() {
      return mView;
   }

   function onSettingsChanged() {
      // triggered by settings change in GCM
      mView.last_draw_minute = -1;
      WatchUi.requestUpdate(); // update the view to reflect changes
   }

   function getFormattedDate() {
      var now = Time.now();
      var date = Date.info(now, Time.FORMAT_SHORT);
      var date_formatter = Application.getApp().getProperty("date_format");
      if (date_formatter == 0) {
         if (Application.getApp().getProperty("force_date_english")) {
            var day_of_week = date.day_of_week;
            return Lang.format("$1$ $2$", [
               days[day_of_week],
               date.day.format("%d"),
            ]);
         } else {
            var long_date = Date.info(now, Time.FORMAT_LONG);
            var day_of_week = long_date.day_of_week;
            return Lang.format("$1$ $2$", [
               day_of_week.toUpper(),
               date.day.format("%d"),
            ]);
         }
      } else if (date_formatter == 1) {
         // dd/mm
         return Lang.format("$1$.$2$", [
            date.day.format("%d"),
            date.month.format("%d"),
         ]);
      } else if (date_formatter == 2) {
         // mm/dd
         return Lang.format("$1$.$2$", [
            date.month.format("%d"),
            date.day.format("%d"),
         ]);
      } else if (date_formatter == 3) {
         // dd/mm/yyyy
         var year = date.year;
         var yy = year / 100.0;
         yy = Math.round((yy - yy.toNumber()) * 100.0);
         return Lang.format("$1$.$2$.$3$", [
            date.day.format("%d"),
            date.month.format("%d"),
            yy.format("%d"),
         ]);
      } else if (date_formatter == 4) {
         // mm/dd/yyyy
         var year = date.year;
         var yy = year / 100.0;
         yy = Math.round((yy - yy.toNumber()) * 100.0);
         return Lang.format("$1$.$2$.$3$", [
            date.month.format("%d"),
            date.day.format("%d"),
            yy.format("%d"),
         ]);
      } else if (date_formatter == 5 || date_formatter == 6) {
         // dd mmm
         var day = null;
         var month = null;
         if (Application.getApp().Properties.getValue("force_date_english")) {
            day = date.day;
            month = months[date.month];
         } else {
            var medium_date = Date.info(now, Time.FORMAT_MEDIUM);
            day = medium_date.day;
            month = months[medium_date.month];
         }
         if (date_formatter == 5) {
            return Lang.format("$1$ $2$", [day.format("%d"), month]);
         } else {
            return Lang.format("$1$ $2$", [month, day.format("%d")]);
         }
      }
   }

   function toKValue(value) {
      var valK = value / 1000.0;
      return valK.format("%0.1f");
   }
}
