# Infocal Custom
Infocal Custom, a watchface for Garmin devices ([Garmin Connect IQ store](https://apps.garmin.com/en-US/apps/a45e74a2-48b5-4c53-9bce-8aae7c685c0b)). This project was forked from [Infocal](https://github.com/RyanDam/Infocal), and would not exist if not for the work RyanDam put into that project.

This project is free and will remain free under the MIT License.

# Description

Infocal is a digital and analogue watchface, carefully made with high quality rendering. It's both customizable and functional. With up to 8 complications on the screen, each complication can show a variety of data:

- Date
- Digital time/2nd timezone
- Battery
- Total/active calories
- Live heart rate
- Distance (day/weekly)
- Move bar
- Daily steps
- Active minutes
- Notification/alarm/connection status
- Altitude
- Temperature (on-device sensor)
- Temperature (Garmin weather)
- Temperature (outside, OpenWaather)
- Temperature (high/low, OpenWeather)
- Sunrise/Sunset time (OpenWeather)
- Floor climbed
- Barometer data
- Countdown to event day
- Weather condition (OpenWeather)
- Body battery
- Stress

Please configure your watch face via Garmin Connect Mobile or Garmin Express. Here is how to do it:

https://forums.garmin.com/developer/connect-iq/w/wiki/14/changing-your-app-settings-in-garmin-express-gcm-ciq-mobile-store

# FAQs

## Why does Infocal Custom need user profile permission?

Infocal Custom needs access to your profile to calculate active calories, distance goal (based on your steps and stride length), and moving distance for a whole week. Infocal Custom does not store this information.

## Why does Infocal Custom need internet/background communication permission?

If using the OpenWeatherMap for any of the features (see feature list above), internet and background communication is used to fetch data from the OpenWeatherMap API.

## Why isn't battery days remaining not working?

The days remaining battery estimate needs about an 1 hour to calibrate before displaying any information. After calibration, the estimate updates once every hour. If you restart your watch or switch to a different watchface, it will need to calibrate again.

## Can I see the connection status between the watch and the phone?

The group notification complication displays a "C" (connected) if the watch is connected to a phone, otherwise it will display "D" (disconnected).

## Why doesn't sunrise/sunset/OpenWeatherMap temperature display any information?

Sunrise/sunset only works if the watch has a GPS signal. Try starting any activity that requires GPS, then wait for GPS signal. Once a GPS signal is established, return to watch face and check the complication again.

## Why is my complication data just showing "--"?

Not all complications are supported for all devices, or there is no data to display at the moment. This could be because the data isn't available (e.g., Stress is not always calculated), or the complication relies on a GPS signal that has not been established.

## A blank square is shown instead of a character?

Currently, this watch face only supports English (or Latin characters).

## How do I get an OpenWeatherMap API?

Go to https://openweathermap.org/, create an account, and log in. Once logged in, click on your account name in the upper right corner, then click on "My API keys". If you do not have any keys, click "Generate" and copy the newly generated key to the Infocal Custom settings.

# Credits (from original Infocal project)

- Special thanks to **[warmsound](https://github.com/warmsound)** for awesome [Crystal Watchface](https://github.com/warmsound/crystal-face). Without Crystal, I'm not able to add some features (suntime, sensor history, weather...) to this watchface.
- Special thanks to **[sunpazed](https://github.com/sunpazed)** for his awesome GitHub projects. I learned a lot from him for anti-aliasing and get inspired to create curved text, which makes Infocal today.
