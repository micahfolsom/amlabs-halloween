# PI-IR

Python code that runs on the Raspberry Pi to drive the projector. The
Pi is connected to an Arduiono that manages an IR emitter and IR sensor.
When a shot is detected by the Arduino, it sets a pin HIGH to tell the
Pi. This code controls the video/animation logic.

Input pins on the Pi:
* TRIGGER PIN = 5
* RESET PIN = 6

To configure a pi, run `./setup.sh`
