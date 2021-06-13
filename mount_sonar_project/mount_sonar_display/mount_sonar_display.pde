// Visual sonar display of the HC-SR04 module and servo; works with mount_sonar.ino

/* Must be started after mount_sonar.ino is run */

import processing.serial.*; // Library needed for serial communication
import processing.sound.*; // Sound library

Serial myPort; // Object from serial class to represent serial port
String SerialData; // Data received from serial port

SoundFile sound_file; // Object from sound library that holds filepath of file to play

PFont myFont; // Font variable
int diameter = 660; // Diameter of radar display major semicircle (centered always at 375, 400)

int servo_angle; // Servo position in degrees
float[] old_distances = new float[166]; // List of old distances to pinged objects at every angle 0-165
float[] new_distances = new float[166]; // List of new distances of pinged objects at every angle 0-65
int servo_motion; // 0 if servo is going anticlockwise, 1 if servo is going clockwise
int scan_cycle; // Current scan cycle
boolean started = false; // Flag indicating whether sonar radar has started scanning

void setup() { // Like with Arduino projects that must have setup() and loop(), all Processing projects must have setup() and draw() functions
  // Only runs one time before draw()
  
  /* Serial port configuration */
 
  String portName = Serial.list()[3]; // Finds serial port Arduino is connected to (COM7)
  myPort = new Serial(this, portName, 9600); // Sets up serial port object. Takes port and budrate as second and third arguments
  // Budrates must match

  /* Window configuration */

  size(750, 450); // Sets the display window size (width, height)
  background(0); // Sets display background colour to black
  
  myFont = createFont("verdana", 11); // Saves font configuration into a variable
  textFont(myFont); // Sets text font
  
  /* Sound configuration */
  
  sound_file = new SoundFile(this, "sonar_ping.wav"); // Variable becomes file pointer
}

void draw() {
  // Loops after setup() is called
  
  background(0); // Clears display window at beginning of each frame
  
  /* Drawing sonar display general features */
  
  fill(0); // Semicircles will have black fill
  stroke(0, 150, 0); // Semicircles and lines will have green border
  
  for (int i=0; i<6; i++) { // Draws all the sonar radar semicircles
    arc(375, 400, diameter-((diameter/6)*i), diameter-((diameter/6)*i), PI, PI*2); // Draws each semicircle increasingly smaller
  }
  
  for (int i=0; i<7; i++) { // Draws all sonar radar sectors 
    line(375, 400, 375-((diameter/2)*cos(radians(30*i))), 400-((diameter/2)*sin(radians(30*i))));
  }
  
  stroke(150, 0, 0); // Scan limit line will be red
  line(375, 400, 375-((diameter/2)*cos(radians(15))), 400-((diameter/2)*sin(radians(15)))); // Scan limit line
  
  /* Drawing sonar display text */
  
  fill(0, 150, 0); // Sets text colour to green (less intense)
  
  for (int i=0; i<6; i++) { // Draws sonar radar distance markers
    text(str(180-(30*i)), 380, 395 - (diameter-((diameter/6)*i))/2);
  }

  text("180°", 375-(diameter/2) - 30, 400); // 180 degree marker
  text("0°", 375+(diameter/2) + 7, 400); // 360 degree marker
  text("90°", 380 - 25, (400-(diameter/2)) - 5); // 90 degree marker
  
  fill(150, 0, 0); // Limit marker will be red
  text("Limit", 340-((diameter/2)*cos(radians(15))), 400-((diameter/2)*sin(radians(15)))); // Scan limit marker
  fill(0, 150, 0); // Resets text colour to green
  
  text("Screen Key:", 10, 20); // Legend subframe
  noStroke(); // No outline for rectangle
  fill(0, 110, 0); // Colour of new distance map
  rect(15, 32, 10, 10);
  fill(0, 150, 0);
  text("New Mapping", 30, 40);
  fill(0, 50, 0); // Colour of old distance map
  rect(15, 50, 10, 10);
  fill(0, 150, 0);
  text("Old Mapping", 30, 60);
  text("Effective Range: ~1.8m", 15, 80);
  text("Effective Angle Range: 165°", 15, 95);
  
  text("Angle: ", 600, 20); // Information subframe
  text(str(servo_angle) + "°", 642, 20);
  text("Distance: ", 600, 35);
  text(str(int(new_distances[servo_angle])) + " cm", 660, 35); 
  text("Motion: ", 600, 50);
  text(servo_motion, 648, 50);
  text("Cycle: ", 600, 65);
  text(scan_cycle, 640, 65);
  
  if (started) { // Only draws scan lines and distance maps
  
    /* Draws scan lines in fading colours */
    
    strokeWeight(2); // Scanning lines have thickness of 2
    if (servo_motion == 0) { // If motion == 0; servo is moving anticlockwise
      for (int i=0; servo_angle < 19 ? i<(servo_angle+1) : i<20; i++) { // Lines drawn brighter to dimmer clockwise
         stroke(0, 190-(10*i), 0); // Defines line colour intensity (0-190 for green)
         line(375, 400, 375+((diameter/2)*cos(radians(servo_angle-i))), 400-((diameter/2)*sin(radians(servo_angle-i))));
      }
    }
    else if (servo_motion == 1) { // If motion == 1; servo is moving clockwise
      for (int i=0; servo_angle > 146 ? i<((165-servo_angle)+1) : i<20; i++) { // Lines drawn dimmer to brighter anticlockwise
         stroke(0, 190-(10*i), 0); // Defines line colour intensity (0-190 for green)
         line(375, 400, 375-((diameter/2)*cos(radians(180-(servo_angle+i)))), 400-((diameter/2)*sin(radians(180-(servo_angle+i)))));
      }
    }
    strokeWeight(1);
    
    /* Draws distance maps (new, old) */
    
    fill(0, 110, 0); // New distance map with bright green 
    
    beginShape(); 
    for (int i=0; i<166; i++) { 
      vertex(375+((new_distances[i]/180)*(diameter/2)*cos(radians(i))), 400-((new_distances[i]/180)*(diameter/2)*sin(radians(i))));
    }
    vertex(375, 400); // Will ensure the distance map will end at radar center
    endShape();
   
    if (scan_cycle > 1) { // Old values available only after first scan
      fill(0, 50, 0); // Old distance map with dark green
      
      beginShape(); 
      for (int i=0; i<166; i++) {
        vertex(375+((old_distances[i]/180)*(diameter/2)*cos(radians(i))), 400-((old_distances[i]/180)*(diameter/2)*sin(radians(i))));
      }
      vertex(375, 400); // Will ensure the distance map will end at radar center
      endShape();  
    }  
  }
}

void serialEvent(Serial myPort) {
  // Function that is called every time serial data is available from serial port
  
   SerialData = myPort.readStringUntil('\n'); // Reads the data sent from the serial port and stores it in val
  
   if (SerialData != null) { // If there is valid data
      started = true; // Started flag set to true
       
      SerialData = trim(SerialData); // Removes any whitespace from string
      
      servo_angle = int(SerialData.substring(0, SerialData.indexOf('A'))); // Parses the servo angle from the serial data
      
      old_distances[servo_angle] = new_distances[servo_angle]; // Old distance value at given angle assumes the value of the new one
      new_distances[servo_angle] = float(SerialData.substring(SerialData.indexOf('A') + 1, SerialData.indexOf('D'))); // Parses the pinged object distance from the serial data
      
      servo_motion = int(SerialData.substring(SerialData.indexOf('D') + 1, SerialData.indexOf('M'))); // Parses the servo motion direction (0 or 1)      
      scan_cycle = int(SerialData.substring(SerialData.indexOf('M') + 1, SerialData.length() - 1)); // Parses the sonar scan cycle number
      
      if (servo_angle == 0 || servo_angle == 165) sound_file.play(); // Plays the sound file if new sweep has been initiated
   }
}
