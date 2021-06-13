// Arduino sonar using the HC-SR04 module and servo; works with mount_sonar_display.pde

/* Must be started before mount_sonar_display.pde is run */

#include <Servo.h> // Servo library

int on_led = 2; // Pin that controls LED that turns on when radar is scanning

int servo_pin = 7; // Pin that controls the servo
int servo_angle = 0; // Current angle of the servo (Also starting angle)
int motion; // If motion is 0, going counterclockwise (forward), if motion is 1, going clockwise (backwards)
int cycle = 0; // Scan cycle number

int trigger = 8; // Digital trigger pin on the HC-SR04
int echo = 9; // Digital receiver pin on the HC-SR04
int pingTravelTime; // Time taken for ping to be sent and come back
float interceptionDistance; // Distance to pinged object in cm

Servo SonarServo; // Creates servo instance

void setup() {
  // put your setup code here, to run once:

  delay(10000); 
  /* 10 second delay is used to allow mount_sonar_display.pde to start in time
  after mount_sonar module is uploaded or restarted */

  Serial.begin(9600); // Begin serial communication

  SonarServo.attach(servo_pin); // Attaches servo to selected digital pin

  pinMode(on_led, OUTPUT); // Pin controlling on LED
  digitalWrite(on_led, HIGH); // Turns LED on when program starts running

  pinMode(trigger, OUTPUT); // Trigger pin will output an ultrasonic ping
  pinMode(echo, INPUT); // Echo pin will listen for ping return
}

void loop() {
  // put your main code here, to run repeatedly:

  SonarServo.write(servo_angle); // Moves the servo to the specified angle

  if (servo_angle == 0) { 
    motion = 0; // Servo must now go anticlockwise
    cycle++; // Cycle has been completed
  }
  else if (servo_angle == 165) {
    motion = 1; // Servo must now go clockwise
    cycle++; // Cycle has been completed
  }

  digitalWrite(trigger, LOW); // Ensures a clean HIGH will be sent
  delayMicroseconds(10);
  digitalWrite(trigger, HIGH); // Sends a 40khz burst of 8 pulses for 10 microseconds
  delayMicroseconds(10);
  digitalWrite(trigger, LOW);

  pingTravelTime = pulseIn(echo, HIGH); // Returns ping travel time in microseconds
  interceptionDistance = 0.017*pingTravelTime; // Calculates the pinged object distance

  Serial.print(servo_angle); // Sends serial data to mount_sonar_display.pde
  Serial.print("A");
  Serial.print(interceptionDistance);
  Serial.print("D");
  Serial.print(motion);
  Serial.print("M");
  Serial.print(cycle);
  Serial.println("C");

  if (motion == 0) servo_angle++; // If moving anticlockwise, add 1 to the angle
  else servo_angle--; // If moving clockwise, subtract 1 to the angle
}
