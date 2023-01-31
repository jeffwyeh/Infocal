using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Application as App;
using Toybox.Activity as Activity;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.SensorHistory as SensorHistory;

using Toybox.UserProfile;
using Toybox.Time;
using Toybox.Time.Gregorian as Date;

enum /* FIELD_TYPES */ {
   FIELD_TYPE_HEART_RATE = 0,
   FIELD_TYPE_BATTERY,
   FIELD_TYPE_CALORIES,
   FIELD_TYPE_DISTANCE,
   FIELD_TYPE_MOVE,
   FIELD_TYPE_STEP,
   FIELD_TYPE_ACTIVE,

   FIELD_TYPE_DATE,
   FIELD_TYPE_TIME,
   FIELD_TYPE_EMPTY,

   FIELD_TYPE_NOTIFICATIONS = 10,
   FIELD_TYPE_ALARMS,
   FIELD_TYPE_ALTITUDE,
   FIELD_TYPE_TEMPERATURE,
   FIELD_TYPE_SUNRISE_SUNSET,
   FIELD_TYPE_FLOOR,
   FIELD_TYPE_GROUP_NOTI,
   FIELD_TYPE_DISTANCE_WEEK,
   FIELD_TYPE_BAROMETER,
   FIELD_TYPE_TIME_SECONDARY,
   FIELD_TYPE_PHONE_STATUS,
   FIELD_TYPE_COUNTDOWN,
   FIELD_TYPE_WEEKCOUNT,

   FIELD_TYPE_TEMPERATURE_OUT = 23,
   FIELD_TYPE_TEMPERATURE_HL,
   FIELD_TYPE_WEATHER,

   FIELD_TYPE_AMPM_INDICATOR = 26,
   FIELD_TYPE_CTEXT_INDICATOR,
   FIELD_TYPE_WIND,
   FIELD_TYPE_BODY_BATTERY,
   FIELD_TYPE_STRESS,
   FIELD_TYPE_BB_STRESS,

   FIELD_TYPE_TEMPERATURE_GARMIN = 32,
   FIELD_TYPE_PRECIPITATION_GARMIN,
   FIELD_TYPE_WEATHER_GARMIN,
   FIELD_TYPE_TEMPERATURE_HL_GARMIN,

   FIELD_TYPE_MODERATE = 36,
   FIELD_TYPE_VIGOROUS,
}

function buildFieldObject(type) {
   if (type == FIELD_TYPE_HEART_RATE) {
      return new HRField(FIELD_TYPE_HEART_RATE);
   } else if (type == FIELD_TYPE_BATTERY) {
      return new BatteryField(FIELD_TYPE_BATTERY);
   } else if (type == FIELD_TYPE_CALORIES) {
      return new CaloField(FIELD_TYPE_CALORIES);
   } else if (type == FIELD_TYPE_DISTANCE) {
      return new DistanceField(FIELD_TYPE_DISTANCE);
   } else if (type == FIELD_TYPE_MOVE) {
      return new MoveField(FIELD_TYPE_MOVE);
   } else if (type == FIELD_TYPE_STEP) {
      return new StepField(FIELD_TYPE_STEP);
   } else if (type == FIELD_TYPE_ACTIVE) {
      return new ActiveField(FIELD_TYPE_ACTIVE);
   } else if (type == FIELD_TYPE_MODERATE) {
      return new ActiveModerateField(FIELD_TYPE_MODERATE);
   } else if (type == FIELD_TYPE_VIGOROUS) {
      return new ActiveVigorousField(FIELD_TYPE_VIGOROUS);
   } else if (type == FIELD_TYPE_DATE) {
      return new DateField(FIELD_TYPE_DATE);
   } else if (type == FIELD_TYPE_TIME) {
      return new TimeField(FIELD_TYPE_TIME);
   } else if (type == FIELD_TYPE_EMPTY) {
      return new EmptyDataField(FIELD_TYPE_EMPTY);
   } else if (type == FIELD_TYPE_NOTIFICATIONS) {
      return new NotifyField(FIELD_TYPE_NOTIFICATIONS);
   } else if (type == FIELD_TYPE_ALARMS) {
      return new AlarmField(FIELD_TYPE_ALARMS);
   } else if (type == FIELD_TYPE_ALTITUDE) {
      return new AltitudeField(FIELD_TYPE_ALTITUDE);
   } else if (type == FIELD_TYPE_TEMPERATURE) {
      return new TemparatureField(FIELD_TYPE_TEMPERATURE);
   } else if (type == FIELD_TYPE_SUNRISE_SUNSET) {
      return new SunField(FIELD_TYPE_SUNRISE_SUNSET);
   } else if (type == FIELD_TYPE_FLOOR) {
      return new FloorField(FIELD_TYPE_FLOOR);
   } else if (type == FIELD_TYPE_GROUP_NOTI) {
      return new GroupNotiField(FIELD_TYPE_GROUP_NOTI);
   } else if (type == FIELD_TYPE_DISTANCE_WEEK) {
      return new WeekDistanceField(FIELD_TYPE_DISTANCE_WEEK);
   } else if (type == FIELD_TYPE_BAROMETER) {
      return new BarometerField(FIELD_TYPE_BAROMETER);
   } else if (type == FIELD_TYPE_TIME_SECONDARY) {
      return new TimeSecondaryField(FIELD_TYPE_TIME_SECONDARY);
   } else if (type == FIELD_TYPE_PHONE_STATUS) {
      return new PhoneField(FIELD_TYPE_PHONE_STATUS);
   } else if (type == FIELD_TYPE_COUNTDOWN) {
      return new CountdownField(FIELD_TYPE_COUNTDOWN);
   } else if (type == FIELD_TYPE_WEEKCOUNT) {
      return new WeekCountField(FIELD_TYPE_WEEKCOUNT);
   } else if (type == FIELD_TYPE_TEMPERATURE_OUT) {
      return new TemparatureOutField(FIELD_TYPE_TEMPERATURE_OUT);
   } else if (type == FIELD_TYPE_TEMPERATURE_HL) {
      return new TemparatureHLField(FIELD_TYPE_TEMPERATURE_HL);
   } else if (type == FIELD_TYPE_WEATHER) {
      return new WeatherField(FIELD_TYPE_WEATHER);
   } else if (type == FIELD_TYPE_AMPM_INDICATOR) {
      return new AMPMField(FIELD_TYPE_AMPM_INDICATOR);
   } else if (type == FIELD_TYPE_CTEXT_INDICATOR) {
      return new CTextField(FIELD_TYPE_CTEXT_INDICATOR);
   } else if (type == FIELD_TYPE_WIND) {
      return new WindField(FIELD_TYPE_WIND);
   } else if (type == FIELD_TYPE_BODY_BATTERY) {
      return new BodyBatteryField(FIELD_TYPE_BODY_BATTERY);
   } else if (type == FIELD_TYPE_STRESS) {
      return new StressField(FIELD_TYPE_STRESS);
   } else if (type == FIELD_TYPE_BB_STRESS) {
      return new BodyBatteryStressField(FIELD_TYPE_BB_STRESS);
   } else if (type == FIELD_TYPE_TEMPERATURE_GARMIN) {
      return new TemparatureGarminField(FIELD_TYPE_TEMPERATURE_GARMIN);
   } else if (type == FIELD_TYPE_PRECIPITATION_GARMIN) {
      return new PrecipitationGarminField(FIELD_TYPE_PRECIPITATION_GARMIN);
   } else if (type == FIELD_TYPE_WEATHER_GARMIN) {
      return new WeatherGarminField(FIELD_TYPE_WEATHER_GARMIN);
   } else if (type == FIELD_TYPE_TEMPERATURE_HL_GARMIN) {
      return new TemperatureHLGarminField(FIELD_TYPE_TEMPERATURE_HL_GARMIN);
   }

   return new EmptyDataField(FIELD_TYPE_EMPTY);
}

class BaseDataField {
   function initialize(id) {
      _field_id = id;
   }

   private var _field_id;

   function field_id() {
      return _field_id;
   }

   function have_secondary() {
      return false;
   }

   function min_val() {
      return 0.0;
   }

   function max_val() {
      return 100.0;
   }

   function cur_val() {
      return 0.01;
   }

   function min_label(value) {
      return "0";
   }

   function max_label(value) {
      return "100";
   }

   function cur_label(value) {
      return "0";
   }

   function need_draw() {
      return true;
   }

   function bar_data() {
      return false;
   }
}

class EmptyDataField {
   function initialize(id) {
      _field_id = id;
   }

   private var _field_id;

   function field_id() {
      return _field_id;
   }

   function need_draw() {
      return false;
   }
}
