using Toybox.WatchUi as Ui;
using Toybox.Math;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;
using Toybox.Time.Gregorian as Date;

class DigitalDial extends Ui.Drawable {
   ////////////////////////
   /// common variables ///
   ////////////////////////
   hidden var digitalFont, xdigitalFont;
   hidden var midDigitalFont;
   hidden var midBoldFont;
   hidden var midSemiFont;
   hidden var xmidBoldFont;
   hidden var xmidSemiFont;
   hidden var barRadius;

   ///////////////////////////////
   /// non-antialias variables ///
   ///////////////////////////////

   hidden var alignment;

   hidden var bonusy_smallsize;

   function initialize(params) {
      Drawable.initialize(params);
      barRadius = center_x - 10;
      alignment = Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER;

      bonusy_smallsize = 0;
      if (center_x == 195) {
         bonusy_smallsize = -35;
      }
   }

   function removeFont() {
      midBoldFont = null;
      midSemiFont = null;
      xmidBoldFont = null;
      xmidSemiFont = null;
      xdigitalFont = null;
      digitalFont = null;
      midDigitalFont = null;
   }

   function checkCurrentFont() {
      var digital_style = Application.getApp().getProperty("digital_style");
      if (digital_style == 0) {
         // big
         midBoldFont = null;
         midSemiFont = null;
         xmidBoldFont = null;
         xmidSemiFont = null;
         xdigitalFont = null;
         if (digitalFont == null) {
            digitalFont = Ui.loadResource(Rez.Fonts.bigdigi);
            midDigitalFont = Ui.loadResource(Rez.Fonts.middigi);
         }
      } else if (digital_style == 1) {
         // small
         xdigitalFont = null;
         digitalFont = null;
         xmidBoldFont = null;
         xmidSemiFont = null;
         midDigitalFont = null;
         if (midBoldFont == null) {
            midBoldFont = Ui.loadResource(Rez.Fonts.midbold);
            midSemiFont = Ui.loadResource(Rez.Fonts.midsemi);
         }
      } else if (digital_style == 2) {
         // extra big
         midBoldFont = null;
         midSemiFont = null;
         digitalFont = null;
         xmidBoldFont = null;
         xmidSemiFont = null;
         if (xdigitalFont == null) {
            xdigitalFont = Ui.loadResource(Rez.Fonts.xbigdigi);
            midDigitalFont = Ui.loadResource(Rez.Fonts.middigi);
         }
      } else {
         // medium
         xdigitalFont = null;
         digitalFont = null;
         midBoldFont = null;
         midSemiFont = null;
         midDigitalFont = null;
         if (xmidBoldFont == null) {
            xmidBoldFont = Ui.loadResource(Rez.Fonts.xmidbold);
            xmidSemiFont = Ui.loadResource(Rez.Fonts.xmidsemi);
         }
      }
   }

   function draw(dc) {
      if (Application.getApp().getProperty("use_analog") == true) {
         removeFont();
         return;
      }
      checkCurrentFont();

      // Get locals
      var second_x_l = second_x;
      var second_y_l = second_y;
      var heart_x_l = heart_x;
      var center_x_l = center_x;
      var center_y_l = center_y;

      var currentSettings = System.getDeviceSettings();
      var clockTime = System.getClockTime();
      var hour = clockTime.hour;
      if (!currentSettings.is24Hour) {
         hour = hour % 12;
         hour = hour == 0 ? 12 : hour;
      }
      var minute = clockTime.min;

      var leading_zeros = Application.getApp().getProperty("zero_leading_digital");
      var number_formater = leading_zeros ? "%02d" : "%d";

      var digital_style = Application.getApp().getProperty("digital_style");
      var alwayon_style = Application.getApp().getProperty("always_on_style");
      if (digital_style == 0 || digital_style == 2) {
         // Big number in center style
         var big_number_type = Application.getApp().getProperty("big_number_type");
         var bignumber = (big_number_type == 0) ? minute : hour;
         var smallnumber = (big_number_type == 0) ? hour : minute;

         var target_center_font = digital_style == 0 ? digitalFont : xdigitalFont;

         // Draw center number
         var bigText = bignumber.format(number_formater);
         dc.setPenWidth(1);
         dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
         var h = dc.getFontHeight(target_center_font);
         var w = dc.getTextWidthInPixels(bigText, target_center_font);
         dc.drawText(
            center_x_l,
            center_y_l - h / 4,
            target_center_font,
            bigText,
            alignment
         );

         // Draw stripes
         if (Application.getApp().getProperty("big_num_stripes")) {
            dc.setColor(gbackground_color, Graphics.COLOR_TRANSPARENT);
            var w2 = dc.getTextWidthInPixels("\\", target_center_font);
            dc.drawText(
               center_x_l + w2 - w / 2,
               center_y_l - h / 4,
               target_center_font,
               "\\",
               Graphics.TEXT_JUSTIFY_VCENTER
            );
         }

         // Calculate global offsets
         var f_align = digital_style == 0 ? 62 : 71;
         if (center_x_l == 195) {
            f_align = f_align + 40;
         }
         second_x_l = center_x_l + w / 2 + 3;
         heart_x_l = center_x_l - w / 2 - 3;
         if (center_x_l == 109 && digital_style == 2) {
            second_y_l =
               center_y_l -
               second_font_height_half / 2 -
               (alwayon_style == 0 ? 3 : 6);
         } else {
            second_y_l =
               center_y_l +
               (h - f_align) / 2 -
               second_font_height_half * 2 +
               (alwayon_style == 0 ? 0 : 5);
         }

         // Draw digital info (small number, date)
         // Calculate alignment
         var bonus_alignment = 0;
         var extra_info_alignment = 0;
         var vertical_alignment = 0;
         if (center_x_l == 109) {
            bonus_alignment = 4;
            if (digital_style == 2) {
               bonus_alignment = 4;
               vertical_alignment = -23;
            }
         } else if (center_x_l == 120 && digital_style == 2) {
            bonus_alignment = 6;
            extra_info_alignment = 4;
         }
         var target_info_x = center_x_l * 1.6;
         var left_digital_info = Application.getApp().getProperty("left_digital_info");
         if (left_digital_info) {
            target_info_x = center_x_l * 0.4;
            bonus_alignment = -bonus_alignment;
            extra_info_alignment = -extra_info_alignment;
         }

         // Draw background of date
         // This is needed to prevent power save mode from re-rendering
         dc.setColor(gbackground_color, Graphics.COLOR_TRANSPARENT);
         dc.setPenWidth(20);
         if (left_digital_info) {
            dc.drawArc(
               center_x_l,
               center_y_l,
               barRadius,
               Graphics.ARC_CLOCKWISE,
               180 - 10,
               120 + 10
            );
         } else {
            dc.drawArc(
               center_x_l,
               center_y_l,
               barRadius,
               Graphics.ARC_CLOCKWISE,
               60 - 10,
               0 + 10
            );
         }
         dc.setPenWidth(1);

         // Draw small number
         dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
         var h2 = dc.getFontHeight(midDigitalFont);
         dc.drawText(
            target_info_x + bonus_alignment,
            center_y_l * 0.7 - h2 / 4 + 5 + vertical_alignment,
            midDigitalFont,
            smallnumber.format(number_formater),
            alignment
         );

         // If there is no room for the date, return and don't draw it
         if (center_x_l == 109 && digital_style == 2) {
            return;
         }

         // Draw date
         var dateText = Application.getApp().getFormattedDate();
         dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
         var h3 = dc.getFontHeight(small_digi_font);
         dc.drawText(
            target_info_x - bonus_alignment + extra_info_alignment,
            center_y_l * 0.4 - h3 / 4 + 7,
            small_digi_font,
            dateText,
            alignment
         );

         // Draw horizontal line
         var w3 = dc.getTextWidthInPixels(dateText, small_digi_font);
         dc.setPenWidth(2);
         dc.setColor(gsecondary_color, Graphics.COLOR_TRANSPARENT);
         dc.drawLine(
            target_info_x - bonus_alignment - w3 / 2 + extra_info_alignment,
            center_y_l * 0.5 + 7,
            target_info_x - bonus_alignment + w3 / 2 + extra_info_alignment,
            center_y_l * 0.5 + 7
         );
      } else if (digital_style == 1 || digital_style == 3) {
         // All numbers in center style
         var hourText = hour.format(number_formater);
         var minuText = minute.format("%02d");

         var bonus = digital_style == 3 ? -13 : 0;
         var boldF = digital_style == 3 ? xmidBoldFont : midBoldFont;
         var normF = digital_style == 3 ? xmidSemiFont : midSemiFont;

         var hourW = dc.getTextWidthInPixels(hourText, boldF).toFloat();
         var h = dc.getFontHeight(boldF).toFloat();
         var minuW = dc.getTextWidthInPixels(minuText, normF).toFloat();
         var half = (hourW + minuW + 6.0) / 2.0;
         var left = center_x_l - half;

         // Draw clock
         dc.setColor(gmain_color, Graphics.COLOR_TRANSPARENT);
         dc.drawText(
            left.toNumber(),
            center_y_l - 70 + bonus + bonusy_smallsize,
            boldF,
            hourText,
            Graphics.TEXT_JUSTIFY_LEFT
         );
         dc.drawText(
            (left + hourW + 6.0).toNumber(),
            center_y_l - 70 + bonus + bonusy_smallsize,
            normF,
            minuText,
            Graphics.TEXT_JUSTIFY_LEFT
         );

         // Calculate global offsets
         var f_align = 40;
         second_x_l = center_x_l + half + 1;
         heart_x_l = center_x_l - half - 1;

         second_y_l =
            center_y_l -
            second_font_height_half / 2 -
            (alwayon_style == 0 ? 3 : 6);
      }

      // Save globals
      second_x = second_x_l;
      second_y = second_y_l;
      heart_x = heart_x_l;

      removeFont();
   }
}
