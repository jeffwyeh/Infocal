using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;

using Toybox.Time.Gregorian as Date;
using Toybox.Application as App;
using Toybox.ActivityMonitor as Mon;
using Toybox.UserProfile;

var small_digi_font = null;
var second_digi_font = null;
var second_x = 160;
var second_y = 140;
var heart_x = 80;
var center_x;
var center_y;

var second_font_height_half = 7;
var second_background_color = 0x000000;
var second_font_color = 0xffffff;
var second_clip_size = null;

// theming
var gbackground_color = 0x000000;
var gmain_color = 0xffffff;
var gsecondary_color = 0xff0000;
var garc_color = 0x555555;
var gbar_color_indi = 0xaaaaaa;
var gbar_color_back = 0x550000;
var gbar_color_0 = 0xffff00;
var gbar_color_1 = 0x0000ff;

var gtheme = -1;

var last_battery_percent = -1;
var last_hour_consumption = -1;

class HuwaiiView extends WatchUi.WatchFace {
   var last_draw_minute = -1;
   var last_resume_milli = 0;
   var restore_from_resume = false;
   var restore_web_requests = false;

   var last_battery_hour = null;

   var font_padding = 12;
   var font_height_half = 7;

   var face_radius;

   var did_clear = false;

   var screenbuffer = null;

   function initialize() {
      WatchFace.initialize();
   }

   // Load your resources here
   function onLayout(dc) {
      small_digi_font = WatchUi.loadResource(Rez.Fonts.smadigi);
      center_x = dc.getWidth() / 2;
      center_y = dc.getHeight() / 2;

      face_radius = center_x - ((18 * center_x) / 120).toNumber();

      setLayout(Rez.Layouts.WatchFace(dc));

      // vivoactive4(s) sometimes clears the watch dc before onupdate
      if (Application.getApp().getProperty("enable_buffering")) {
         // create a buffer to draw to
         // so it can be pasted straight to
         // the screen instead of redrawing
         var params = {
            :width => dc.getWidth(),
            :height => dc.getHeight(),
         };
         if (Toybox.Graphics has :createBufferedBitmap) {
            screenbuffer = Graphics.createBufferedBitmap(params).get();
         } else if (Toybox.Graphics has :BufferedBitmap) {
            screenbuffer = new Graphics.BufferedBitmap(params);
         }
      }
      checkGlobals();
   }

   // Called when this View is brought to the foreground. Restore
   // the state of this View and prepare it to be shown. This includes
   // loading resources into memory.
   function onShow() {
      last_draw_minute = -1;
      restore_from_resume = true;
      restore_web_requests = true;
      last_resume_milli = System.getTimer();
      checkBackgroundRequest();
   }

   // Update the view
   function onUpdate(dc) {
      var clockTime = System.getClockTime();
      var current_milli = System.getTimer();
      var minute_changed = clockTime.min != last_draw_minute;

      // Calculate battery consumption in days
      var time_now = Time.now();
      if (last_battery_hour == null) {
         last_battery_hour = time_now;
         last_battery_percent = System.getSystemStats().battery;
         last_hour_consumption = -1;
      } else if (time_now.compare(last_battery_hour) >= 60 * 60) {
         // 60 min
         last_battery_hour = time_now;
         var current_battery = System.getSystemStats().battery;
         var temp_last_battery_percent = last_battery_percent;
         var temp_last_hour_consumption = temp_last_battery_percent - current_battery;
         if (temp_last_hour_consumption < 0) {
            temp_last_hour_consumption = -1;
         }
         if (temp_last_hour_consumption > 0) {
            App.getApp().setProperty(
               "last_hour_consumption",
               temp_last_hour_consumption
            );

            var consumption_history =
               App.getApp().getProperty("consumption_history");
            if (consumption_history == null) {
               App.getApp().setProperty("consumption_history", [
                  temp_last_hour_consumption,
               ]);
            } else {
               consumption_history.add(temp_last_hour_consumption);
               if (consumption_history.size() > 24) {
                  var object0 = consumption_history[0];
                  consumption_history.remove(object0);
               }
               App.getApp().setProperty(
                  "consumption_history",
                  consumption_history
               );
            }
         }
         last_battery_percent = current_battery;
         last_hour_consumption = temp_last_hour_consumption;
      }

      // if this device has the clear dc bug
      // use a screen buffer to save having to redraw
      // everything on every update
      if (
         Application.getApp().getProperty("power_save_mode") &&
         screenbuffer != null
      ) {
         // if minute has changed, draw to the buffer
         if (minute_changed) {
            last_draw_minute = clockTime.min;
            minute_changed = false;
            mainDrawComponents(screenbuffer.getDc());
         }
         // copy buffer to screen
         dc.drawBitmap(0, 0, screenbuffer);
      }

      if (restore_web_requests || minute_changed) {
         // After resuming (`onShow()` called), allow web requests
         // to keep trying for 5s, or allow it on the minute change
         if (restore_web_requests && (current_milli - last_resume_milli > 5000)) {
            restore_web_requests = false;
         }
         checkBackgroundRequest();
      }

      if (Application.getApp().getProperty("power_save_mode")) {
         if (restore_from_resume || minute_changed) {
            if (restore_from_resume) {
               restore_from_resume = false;
            }
            last_draw_minute = clockTime.min;
            minute_changed = false;
            mainDrawComponents(dc);
         }
      } else {
         if (minute_changed) {
            last_draw_minute = clockTime.min;
         }
         if (restore_from_resume) {
            restore_from_resume = false;
         }
         mainDrawComponents(dc);
      }

      // Update always on seconds and HR
      onPartialUpdate(dc);
   }

   function mainDrawComponents(dc) {
      dc.setColor(Graphics.COLOR_TRANSPARENT, gbackground_color);
      dc.clear();
      dc.setColor(gbackground_color, Graphics.COLOR_TRANSPARENT);
      dc.fillRectangle(0, 0, center_x * 2, center_y * 2);

      var backgroundView = View.findDrawableById("background");
      var bar1 = View.findDrawableById("aBarDisplay");
      var bar2 = View.findDrawableById("bBarDisplay");
      var bar3 = View.findDrawableById("cBarDisplay");
      var bar4 = View.findDrawableById("dBarDisplay");
      var bar5 = View.findDrawableById("eBarDisplay");
      var bar6 = View.findDrawableById("fBarDisplay");
      var bbar1 = View.findDrawableById("bUBarDisplay");
      var bbar2 = View.findDrawableById("tUBarDisplay");

      bar1.draw(dc);
      bar2.draw(dc);
      bar3.draw(dc);
      bar4.draw(dc);
      bar5.draw(dc);
      bar6.draw(dc);

      dc.setColor(gbackground_color, Graphics.COLOR_TRANSPARENT);
      dc.fillCircle(center_x, center_y, face_radius);

      backgroundView.draw(dc);
      bbar1.draw(dc);
      bbar2.draw(dc);

      var bgraph1 = View.findDrawableById("tGraphDisplay");
      var bgraph2 = View.findDrawableById("bGraphDisplay");
      bgraph1.draw(dc);
      bgraph2.draw(dc);

      if (Application.getApp().getProperty("use_analog")) {
         View.findDrawableById("analog").draw(dc);
      } else {
         View.findDrawableById("digital").draw(dc);
      }
   }

   function onPartialUpdate(dc) {
      if (!Application.getApp().getProperty("use_analog")) {
         if (Application.getApp().getProperty("always_on_second")) {
            var clockTime = System.getClockTime();
            var second_text = clockTime.sec.format("%02d");

            dc.setClip(
               second_x,
               second_y,
               second_clip_size[0],
               second_clip_size[1]
            );
            dc.setColor(Graphics.COLOR_TRANSPARENT, gbackground_color);
            dc.clear();
            dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
               second_x,
               second_y - font_padding,
               second_digi_font,
               second_text,
               Graphics.TEXT_JUSTIFY_LEFT
            );
            dc.clearClip();
         }

         if (Application.getApp().getProperty("always_on_heart")) {
            var h = _retrieveHeartrate();
            var heart_text = "--";
            if (h != null) {
               heart_text = h.format("%d");
            }
            var ss = dc.getTextDimensions(heart_text, second_digi_font);
            var s = (ss[0] * 1.2).toNumber();
            var s2 = (second_clip_size[0] * 1.25).toNumber();
            dc.setClip(heart_x - s2 - 1, second_y, s2 + 2, second_clip_size[1]);
            dc.setColor(Graphics.COLOR_TRANSPARENT, gbackground_color);
            dc.clear();

            dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
               heart_x - 1,
               second_y - font_padding,
               second_digi_font,
               heart_text,
               Graphics.TEXT_JUSTIFY_RIGHT
            );
            dc.clearClip();
         }
      }
   }

   // Called when this View is removed from the screen. Save the
   // state of this View here. This includes freeing resources from
   // memory.
   function onHide() {
   }

   // The user has just looked at their watch. Timers and animations may be started here.
   function onExitSleep() {
      var dialDisplay = View.findDrawableById("analog");
      if (dialDisplay != null) {
         dialDisplay.enableSecondHand();
      }
      checkBackgroundRequest();
   }

   // Terminate any active timers and prepare for slow updates.
   function onEnterSleep() {
      if (Application.getApp().getProperty("use_analog")) {
         var dialDisplay = View.findDrawableById("analog");
         if (dialDisplay != null) {
            dialDisplay.disableSecondHand();
         }
      } else {
         if (Application.getApp().getProperty("always_on_second")) {
            var dc = screenbuffer.getDc();
            dc.setClip(
               second_x,
               second_y,
               second_clip_size[0],
               second_clip_size[1]
            );
            dc.setColor(Graphics.COLOR_TRANSPARENT, gbackground_color);
            dc.clear();
         }
      }
   }

   function checkGlobals() {
      checkTheme();
      checkAlwaysOnStyle();
   }

   function checkTheme() {
      var theme_code = Application.getApp().getProperty("theme_code");
      if (gtheme != theme_code || theme_code == 18) {
         if (theme_code == 18) {
            var background_color =
               Application.getApp().getProperty("background_color");
            var text_color =
               Application.getApp().getProperty("text_color");
            var accent_color =
               Application.getApp().getProperty("accent_color");
            var bar_background_color =
               Application.getApp().getProperty(
                  "bar_background_color"
               );
            var indicator_ticks_color =
               Application.getApp().getProperty("indicator_ticks_color");
            var bar_graph_color_top = Application.getApp().getProperty(
               "bar_graph_color_top"
            );
            var bar_graph_color_bottom =
               Application.getApp().getProperty(
                  "bar_graph_color_bottom"
               );
            if (
               background_color != gbackground_color ||
               text_color != gmain_color ||
               accent_color != gsecondary_color ||
               bar_background_color != gbar_color_back ||
               indicator_ticks_color != gbar_color_indi ||
               bar_graph_color_top != gbar_color_0 ||
               bar_graph_color_bottom != gbar_color_1
            ) {
               // background
               gbackground_color = background_color;
               // main text
               gmain_color = text_color;
               // accent (dividers between complications)
               gsecondary_color = accent_color;
               // ticks
               garc_color = indicator_ticks_color;
               // indicator pointing at the bar
               gbar_color_indi = indicator_ticks_color;
               // bar background
               gbar_color_back = bar_background_color;
               // bar foreground/graph (top)
               gbar_color_0 = bar_graph_color_top;
               // bar foreground/graph (bottom)
               gbar_color_1 = bar_graph_color_bottom;
            }
         } else {
            var theme_pallete = WatchUi.loadResource(
               Rez.JsonData.theme_pallete
            );
            var theme = theme_pallete["" + theme_code];
            // background
            gbackground_color = theme[0];
            // main text
            gmain_color = theme[1];
            // accent (dividers between complications)
            gsecondary_color = theme[2];
            // ticks
            garc_color = theme[3];
            // indicator pointing at the bar
            gbar_color_indi = theme[4];
            // bar background
            gbar_color_back = theme[5];
            // bar foreground/graph (top)
            gbar_color_0 = theme[6];
            // bar foreground/graph (bottom)
            gbar_color_1 = theme[7];
         }
         // set the global theme
         gtheme = theme_code;
      }
   }

   function checkAlwaysOnStyle() {
      var always_on_style = Application.getApp().getProperty("always_on_style");
      if (center_x == 195) {
         if (always_on_style == 0) {
            second_digi_font = WatchUi.loadResource(Rez.Fonts.secodigi);
            second_font_height_half = 16;
            second_clip_size = [40, 30];
         } else {
            second_digi_font = WatchUi.loadResource(Rez.Fonts.xsecodigi);
            second_font_height_half = 16;
            second_clip_size = [52, 44];
         }
      } else {
         if (always_on_style == 0) {
            second_digi_font = WatchUi.loadResource(Rez.Fonts.secodigi);
            second_font_height_half = 7;
            second_clip_size = [20, 15];
         } else {
            second_digi_font = WatchUi.loadResource(Rez.Fonts.xsecodigi);
            second_font_height_half = 14;
            second_clip_size = [26, 22];
         }
      }
   }

   function removeAllFonts() {
      View.findDrawableById("analog").removeFont();
      View.findDrawableById("digital").removeFont(); 
   }

   function checkBackgroundRequest() {
      if (HuwaiiApp has :checkPendingWebRequests) {
         // checkPendingWebRequests() can be excluded to save memory.
         App.getApp().checkPendingWebRequests(); // Depends on mDataFields.hasField().
      }
   }
}
