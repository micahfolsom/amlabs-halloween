/*
 * created by Rui Santos, https://randomnerdtutorials.com
 * Complete Guide for Ultrasonic Sensor HC-SR04
Ultrasonic sensor Pins:
    VCC: +5VDC
    Trig : Trigger (INPUT)
    Echo: Echo (OUTPUT)
    GND: GND
 */
 
struct Timer {
  unsigned long start;
  unsigned long duration;
};

int trigPin = 6;    // Trigger
int echoPin = 7;    // Echo
int const NROAR = 5;
// Output pins going to sound board
int roarPins[NROAR] = {8, 9, 10, 11, 12};
int currRoar = 0;
long duration, cm, inches;
struct Timer roar_cooldown;
// Time before it can trigger again
int const RESET_TIME = 5000; // seconds
float const MIN_TRIGGER_DISTANCE = 10.0; // cm
float const MAX_TRIGGER_DISTANCE = 150.0; // cm
 
void setup() {
  // Serial Port begin
  Serial.begin (9600);
  // Define inputs and outputs
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  for (int i=0;i < NROAR;++i) {
    pinMode(roarPins[i], OUTPUT);
    // Sound board will play when PIN 2 goes LOW
    // Must be LOW for ~500 ms - short pulses do not
    // trigger
    digitalWrite(roarPins[i], HIGH);
  }

  roar_cooldown.duration = RESET_TIME; // ms
  roar_cooldown.start = millis() - RESET_TIME + 1000;
}
 
void loop() {
  // The sensor is triggered by a HIGH pulse of 10 or more microseconds.
  // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
  digitalWrite(trigPin, LOW);
  delayMicroseconds(5);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
 
  // Read the signal from the sensor: a HIGH pulse whose
  // duration is the time (in microseconds) from the sending
  // of the ping to the reception of its echo off of an object.
  pinMode(echoPin, INPUT);
  duration = pulseIn(echoPin, HIGH);
 
  // Convert the time into a distance
  cm = (duration/2) / 29.1;     // Divide by 29.1 or multiply by 0.0343
  inches = (duration/2) / 74;   // Divide by 74 or multiply by 0.0135
  
  Serial.print(inches);
  Serial.print("in, ");
  Serial.print(cm);
  Serial.print("cm");
  Serial.println();

  bool can_roar = true;
  unsigned long elapsed = millis() - roar_cooldown.start;
  if (elapsed < roar_cooldown.duration) {
    can_roar = false;
  }
  if ((cm > MIN_TRIGGER_DISTANCE) && (cm < MAX_TRIGGER_DISTANCE) && can_roar) {
    digitalWrite(roarPins[currRoar], LOW);
    delay(500);
    digitalWrite(roarPins[currRoar], HIGH);
    roar_cooldown.start = millis();
    Serial.print("ROAR");
    Serial.println();
    currRoar++;
    if (currRoar >= NROAR) {
      currRoar = 0;
    }
  }
  
  delay(500);
}
