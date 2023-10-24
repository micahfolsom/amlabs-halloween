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
#include <IRremote.hpp>

struct Timer {
  unsigned long start;
  unsigned long duration;
};

uint8_t sRepeats = 2;
struct Timer send_timer;
int const RPI_TRIGGER_PIN = 4;
int const RPI_RESET_PIN = 5;
int const NPROJECTORS = 3;
// 0, 1, or 2
int const THIS_PROJECTOR = 0;
// These correspond to 1, 2, and 3 on the remote
int const RESET_CODES[NPROJECTORS] = { 0x0C, 0x18, 0x5E };
int const TRIGGER_CODES[NPROJECTORS] = { 0xAB, 0xCD, 0xEF };
int const CONFIRM_CODES[NPROJECTORS] = { 0xBA, 0xDC, 0xFE };

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

    // Pi comms
    pinMode(RPI_TRIGGER_PIN, OUTPUT);
    pinMode(RPI_RESET_PIN, OUTPUT);
}

void loop() {
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

        /*
         * !!!Important!!! Enable receiving of the next value,
         * since receiving has stopped after the end of the current received data packet.
         */
        IrReceiver.resume(); // Enable receiving of the next value

        /*
         * Finally, check the received data and perform actions according to the received command
         */
        uint16_t cmd = IrReceiver.decodedIRData.command;
        if (cmd == TRIGGER_CODES[THIS_PROJECTOR]) {
          Serial.println("Got " + cmd);
          Serial.println();
          Serial.print(F("Sending back confirmation signal"));
          Serial.print(F(", repeats="));
          Serial.print(sRepeats);
          Serial.println();
          Serial.flush();

          // Send signal back confirming shot
          IrSender.sendNEC(0x00, CONFIRM_CODES[THIS_PROJECTOR], sRepeats);
          digitalWrite(RPI_TRIGGER_PIN, HIGH);
          delay(10);
          digitalWrite(RPI_TRIGGER_PIN, LOW);
        } else if (cmd == RESET_CODES[THIS_PROJECTOR]) {
          Serial.print(F("Received reset signal!"));
          digitalWrite(RPI_RESET_PIN, HIGH);
          delay(10);
          digitalWrite(RPI_RESET_PIN, LOW);
        } else {
          Serial.print(F("Got something else: "));
          Serial.println(cmd);
        }
    }
}