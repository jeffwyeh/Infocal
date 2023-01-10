using Toybox.Application as App;

/* CUSTOM TEXT */
class CTextField extends BaseDataField {
   function initialize(id) {
      BaseDataField.initialize(id);
   }

   function cur_label(value) {
      var custom_text = App.getApp().getProperty("ctext_input");
      if (custom_text.length() == 0) {
         return "--";
      }
      return custom_text;
   }
}
