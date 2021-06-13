// Resets the position of the sonar to 0 degrees

#include <Servo.h> // Servo library

int servo_pin = 7; // Pin that controls the servo

Servo SonarServo; // Creates servo instance

void setup() {
  // put your setup code here, to run once:

  SonarServo.attach(servo_pin); // Attaches servo to selected digital pin
  SonarServo.write(0); // Resets position of servo back to 0 degrees
}

void loop() {
  // put your main code here, to run repeatedly:

}
