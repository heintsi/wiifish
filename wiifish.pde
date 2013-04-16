/*
Fishing game for Wiimote.
*/
 
import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;
int wiiMoteId = -1;

boolean rumble = false;
boolean leds = false;

WiiControl wiiControl;


void setup() {
  size(400,400);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  /* send outgoing messages to port 3001 */
  myRemoteLocation = new NetAddress("127.0.0.1",3001);
  
  wiiControl = new WiiControl(myRemoteLocation);
}


void draw() {
  background(wiiControl.triggerPressed() ? color(255,0,0) : 0);  
  if (wiiControl.getId() > -1) {
    wiiControl.update();
  }
}

void mousePressed() {
  wiiControl.fishNibbles(2);
}

void keyPressed() {
  if (keyCode == UP) {
    leds = !leds;
    wiiControl.setLeds(leds,!leds,!leds,leds);
  }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  wiiControl.oscEvent(theOscMessage);
}

void printAcc(float x, float y, float z) {
  System.out.printf("x: %f, y: %f, z: %f\n", x, y, z);
}
