using Toybox.System as Sys;

/* NOTIFICATIONS */
class NotifyField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var settings = Sys.getDeviceSettings();
      value = settings.notificationCount;
      return Lang.format("NOTIF $1$", [value.format("%d")]);
   }
}

/* PHONE STATUS */
class PhoneField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var settings = Sys.getDeviceSettings();
      if (settings.phoneConnected) {
         return "CONN";
      } else {
         return "--";
      }
   }
}

/* GROUP NOTIFICATION */
class GroupNotiField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var settings = Sys.getDeviceSettings();
      value = settings.alarmCount;
      var alarm_str = Lang.format("A$1$", [value.format("%d")]);
      value = settings.notificationCount;
      var noti_str = Lang.format("N$1$", [value.format("%d")]);

      if (settings.phoneConnected) {
         return Lang.format("$1$-$2$-C",[noti_str, alarm_str]);
      } else {
         return Lang.format("$1$-$2$-D",[noti_str, alarm_str]);
      }
   }
}
