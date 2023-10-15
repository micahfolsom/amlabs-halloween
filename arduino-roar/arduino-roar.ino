/*
 * created by Rui Santos, https://randomnerdtutorials.com
 * 
 * Complete Guide for Ultrasonic Sensor HC-SR04
 *
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

int trigPin = 7;    // Trigger
int echoPin = 8;    // Echo
int roarPin = 9;    // Output to sound board
long duration, cm, inches;
struct Timer roar_cooldown;
 
void setup() {
  // Serial Port begin
  Serial.begin (9600);
  // Define inputs and outputs
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(roarPin, OUTPUT);
  // Sound board will play when PIN 2 goes LOW
  // Must be LOW for ~500 ms - short pulses do not
  // trigger
  digitalWrite(roarPin, HIGH);
  roar_cooldown.duration = 10000; // ms
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
  unsigned long current_time = millis();
  if ((current_time - roar_cooldown.start) < roar_cooldown.duration) {
    can_roar = false;
  }
  if ((cm < 30.0) && can_roar) {
    digitalWrite(roarPin, LOW);
    delay(500);
    digitalWrite(roarPin, HIGH);
    roar_cooldown.start = millis();
    Serial.print("ROAR");
    Serial.println();
  }
  
  delay(500);
}