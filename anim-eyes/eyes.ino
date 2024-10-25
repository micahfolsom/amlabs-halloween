#include "fb_gfx.h"
#include "fd_forward.h"
#include "soc/rtc_cntl_reg.h"  //禁止掉电检测
#include "soc/soc.h"           //禁止掉电检测

// Arduino like analogWrite
// value has to be between 0 and valueMax
#define COUNT_LOW 1638
#define COUNT_HIGH 7864

void ledcAnalogWrite(uint8_t channel, uint32_t value, uint32_t valueMax = 180)
{
  // calculate duty, 8191 from 2 ^ 13 - 1
  if(value > valueMax)value = valueMax;
  uint32_t duty = COUNT_LOW + (((COUNT_HIGH - COUNT_LOW ) / valueMax) * value);
  ledcWrite(channel, duty);
}

int const PAN_CENTER = 90; // center the pan servo
int const TILT_CENTER = 90; // center the tilt servo

// ===== CAMERA_MODEL_AI_THINKER =========
#define LED_BUILTIN       4

void setup()
{
  pinMode(LED_BUILTIN, OUTPUT);

  Serial.begin(115200);
  Serial.println();

  // Ai-Thinker: pins 2 and 12
  ledcSetup(2, 50, 16); //channel, freq, resolution
  ledcAttachPin(2, 2); // pin, channel

  ledcSetup(4, 50, 16);
  ledcAttachPin(12, 4);

  ledcAnalogWrite(2, PAN_CENTER); // channel, 0-180
  delay(1000);
  ledcAnalogWrite(4, TILT_CENTER);
}

void loop() {
  ledcAnalogWrite(2, 0);
  ledcAnalogWrite(4, 0);
  delay(2000);
  ledcAnalogWrite(2, 45);
  ledcAnalogWrite(4, 45);
  delay(2000);
  ledcAnalogWrite(2, 135);
  ledcAnalogWrite(4, 135);
  delay(2000);
  ledcAnalogWrite(2, 180);
  ledcAnalogWrite(4, 180);
  delay(2000);
}