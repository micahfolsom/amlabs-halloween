/*
 * SimpleReceiver.cpp
 *
 * Demonstrates receiving NEC IR codes with IRremote
 *
 *  This file is part of Arduino-IRremote https://github.com/Arduino-IRremote/Arduino-IRremote.
 *
 ************************************************************************************
 * MIT License
 *
 * Copyright (c) 2020-2023 Armin Joachimsmeyer
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished
 * to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
 * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 ************************************************************************************
 */

/*
 * Specify which protocol(s) should be used for decoding.
 * If no protocol is defined, all protocols (except Bang&Olufsen) are active.
 * This must be done before the #include <IRremote.hpp>
 */
#define DECODE_NEC          // Includes Apple and Onkyo
#include <Arduino.h>
#include "PinDefinitionsAndMore.h"
#include <IRremote.hpp> // include the library
#include <Adafruit_DotStar.h>
#include <SPI.h>

struct Timer {
  unsigned long start;
  unsigned long duration;
};

uint8_t sRepeats = 4;
int const TRIGGER_PIN = 4;
int const LED_CLOCK_PIN = 5;
int const TRIGGER_LED_PIN = 6;
int const NLEDS = 22;
int const NGUNS = 3;
// 0, 1, or 2
int const THIS_GUN = 0;
int const TRIGGER_CODES[NGUNS] = { 0xAB, 0xCD, 0xEF };
int const CONFIRM_CODES[NGUNS] = { 0xBA, 0xDC, 0xFE };
Adafruit_DotStar strip(NLEDS, TRIGGER_LED_PIN, LED_CLOCK_PIN, DOTSTAR_BRG);
int const MAX_HITS = 3;
int nHits = 0;
struct Timer retrigger_cooldown;
struct Timer reset_hold_timer;
bool reset_initiated = false;

void setup() {
    Serial.begin(115200);
    // Just to know which program is running on my Arduino
    Serial.println(F("START " __FILE__ " from " __DATE__ "\r\nUsing library version " VERSION_IRREMOTE));

    // Start the receiver and if not 3. parameter specified, take LED_BUILTIN pin from the internal boards definition as default feedback LED
    IrReceiver.begin(IR_RECEIVE_PIN, ENABLE_LED_FEEDBACK);

    Serial.print(F("Ready to receive IR signals of protocols: "));
    printActiveIRProtocols(&Serial);
    Serial.println(F("at pin " STR(IR_RECEIVE_PIN)));

    // Set up sender pin
    pinMode(LED_BUILTIN, OUTPUT);
    Serial.print(F("Send IR signals at pin "));
    Serial.println(IR_SEND_PIN);
    IrSender.begin(DISABLE_LED_FEEDBACK);
    retrigger_cooldown.duration = 1000;
    reset_hold_timer.duration = 5000;

    // Set up LED and trigger button pins
    strip.begin();
    //strip.show();
    pinMode(TRIGGER_PIN, INPUT);
    pinMode(TRIGGER_LED_PIN, OUTPUT);
    pinMode(LED_CLOCK_PIN, OUTPUT);
}

void loop() {
  int trigger_val = digitalRead(TRIGGER_PIN);
  if (trigger_val == HIGH) {
    // Shoot
    int elapsed = millis() - retrigger_cooldown.start;
    bool off_cooldown = elapsed >= retrigger_cooldown.duration;
    if (off_cooldown) {
      Serial.print(F("Trigger pulled!"));
      Serial.println();
      Serial.flush();
      IrSender.sendNEC(0x00, TRIGGER_CODES[THIS_GUN], sRepeats);
      strip.fill(strip.Color(150, 0, 150), 0, NLEDS);
      strip.show();
      delay(200);
      strip.fill(strip.Color(0, 0, 0), 0, NLEDS);
      strip.show();
      retrigger_cooldown.start = millis();
      reset_hold_timer.start = millis();
      reset_initiated = true;
    }
    if (reset_initiated) {
      elapsed = millis() - reset_hold_timer.start;
      if (elapsed >= reset_hold_timer.duration) {
        nHits = 0;
        strip.clear();
        reset_initiated = false;
      }
    }
  } else {
    reset_initiated = false;
  }
  /*
  * Check if received data is available and if yes, try to decode it.
  * Decoded result is in the IrReceiver.decodedIRData structure.
  *
  * E.g. command is in IrReceiver.decodedIRData.command
  * address is in command is in IrReceiver.decodedIRData.address
  * and up to 32 bit raw data in IrReceiver.decodedIRData.decodedRawData
  */
  if (IrReceiver.decode()) {
    /*
    * Print a short summary of received data
    */
    IrReceiver.printIRResultShort(&Serial);
    IrReceiver.printIRSendUsage(&Serial);
    if (IrReceiver.decodedIRData.protocol == UNKNOWN) {
      Serial.println(F("Received noise or an unknown (or not yet enabled) protocol"));
      // We have an unknown protocol here, print more info
      IrReceiver.printIRResultRawFormatted(&Serial, true);
    }
    Serial.println();
    /* !!!Important!!! Enable receiving of the next value,
    * since receiving has stopped after the end of the current received data packet.
    */
    IrReceiver.resume(); // Enable receiving of the next value
    if (IrReceiver.decodedIRData.command == CONFIRM_CODES[THIS_GUN]) {
      Serial.println("Received hit confirmation");
      // They just shot, and there's no delay on generating the return
      // signal for accuracy
      // Wait a short time so the "shot" lighting has a chance to happen
      delay(100);
      nHits++;
      if (nHits == 1) {
        for (int i=0;i < 10;++i) {
          strip.fill(strip.Color(255, 0, 0), 0, (i / 2) + 1);
          strip.setBrightness(i * (255.5 / 9.0));
          strip.show();
          delay(100);
        }
      } else if (nHits == 2) {
        for (int i=0;i < 12;++i) {
          strip.fill(strip.Color(255, 0, 0), 0, i + 1);
          strip.setBrightness(i * (255.5 / 11.0));
          strip.show();
          delay(83);
        }
      } else if (nHits == 3) {
        for (int i=0;i < 12;++i) {
          strip.fill(strip.Color(255, 0, 0), 0, (2 * i) + 1);
          strip.setBrightness(i * (255.5 / 11.0));
          strip.show();
          delay(83);
        }
      }
    }
  }
}