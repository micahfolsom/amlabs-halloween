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

int const NGUNS = 3;
struct Timer {
  unsigned long start;
  unsigned long duration;
};
int const TRIGGER_PIN = 4;
int const LED_CLOCK_PIN = 5;
int const TRIGGER_LED_PIN = 6;
int const NLEDS = 22;
Adafruit_DotStar strip(NLEDS, TRIGGER_LED_PIN, LED_CLOCK_PIN, DOTSTAR_BRG);
enum GunColor { RED_GHOST=0, PINK_GHOST, YELLOW_GHOST };
uint32_t const RED_COLOR = strip.Color(0, 255, 0);
uint32_t const PINK_COLOR = strip.Color(0, 255, 255);
uint32_t const YELLOW_COLOR = strip.Color(255, 255, 0);
uint32_t const ALL_COLORS[NGUNS] = { RED_COLOR, PINK_COLOR, YELLOW_COLOR };
/************************************/
/******* SET ME! ********************/
int const THIS_GUN = YELLOW_GHOST;
/************************************/

uint8_t sRepeats = 4;
uint32_t const THIS_GUN_COLOR = ALL_COLORS[THIS_GUN];
int const TRIGGER_CODES[NGUNS] = { 0xAB, 0xCD, 0xEF };
int const CONFIRM_CODES[NGUNS] = { 0xBA, 0xDC, 0xFE };
int const MAX_HITS = 3;
int nHits = 0;
struct Timer retrigger_cooldown;
struct Timer reset_hold_timer;
bool reset_initiated = false;
struct Timer bounceback_cooldown;

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
    retrigger_cooldown.start = millis();
    reset_hold_timer.duration = 5000;
    reset_hold_timer.start = millis();
    bounceback_cooldown.duration = 2000;
    bounceback_cooldown.start = millis();

    // Set up LED and trigger button pins
    strip.begin();
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
    if (off_cooldown && !reset_initiated) {
      if (nHits < 3) {
        Serial.print(F("Trigger pulled!"));
        Serial.println();
        Serial.flush();
        IrSender.sendNEC(0x00, TRIGGER_CODES[THIS_GUN], sRepeats);
        strip.fill(THIS_GUN_COLOR, 0, NLEDS);
        strip.show();
        delay(100);
        strip.clear();
        strip.show();
        strip.fill(THIS_GUN_COLOR, 0, NLEDS);
        strip.show();
        delay(100);
        strip.clear();
        strip.show();
        strip.fill(THIS_GUN_COLOR, 0, NLEDS);
        strip.show();
        delay(100);
        strip.clear();
        strip.show();
      } else {
          for (int i=0;i < 12;++i) {
            strip.setBrightness(255.0 - (i * (255.5 / 11.0)));
            strip.show();
            delay(40);
          }
          for (int i=0;i < 12;++i) {
            strip.setBrightness(i * (255.5 / 11.0));
            strip.show();
            delay(40);
          }
      }
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
        Serial.println(F("Reset triggered by holding"));
        for (int i=0;i < 3;++i) {
          strip.fill(strip.Color(200, 200, 200), 0, NLEDS);
          strip.show();
          delay(200);
          strip.clear();
          strip.show();
          delay(200);
        }
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
      int elapsed = millis() - bounceback_cooldown.start;
      bool off_cooldown = elapsed >= bounceback_cooldown.duration;
      if (off_cooldown) {
        bounceback_cooldown.start = millis();
        // They just shot, and there's no delay on generating the return
        // signal for accuracy
        // Wait a short time so the "shot" lighting has a chance to happen
        nHits++;
        if (nHits == 1) {
          for (int i=0;i < 10;++i) {
            Serial.println("Hits = 1");
            strip.fill(THIS_GUN_COLOR, 0, (i / 2) + 1);
            strip.setBrightness(i * (255.5 / 9.0));
            strip.show();
            delay(100);
          }
        } else if (nHits == 2) {
          for (int i=0;i < 12;++i) {
            Serial.println("Hits = 2");
            strip.fill(THIS_GUN_COLOR, 0, i + 1);
            strip.setBrightness(i * (255.5 / 11.0));
            strip.show();
            delay(83);
          }
        } else if (nHits >= 3) {
          Serial.println("Hits = 3");
          for (int i=0;i < 12;++i) {
            strip.fill(THIS_GUN_COLOR, 0, (2 * i) + 1);
            strip.setBrightness(i * (255.5 / 11.0));
            strip.show();
            delay(83);
          }
        }
      }
    } else {
      Serial.print("Got something else: ");
      Serial.print(IrReceiver.decodedIRData.command, HEX);
      Serial.println();
      Serial.flush();
    }
  }
}
