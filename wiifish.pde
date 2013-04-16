/*

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
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("127.0.0.1",3001);
  
  wiiControl = new WiiControl(myRemoteLocation);
}


void draw() {
  background(rumble ? color(255,0,0) : 0);  
  if (wiiControl.getId() > -1) {
    wiiControl.update();
    //printAcc(wiiControl.getAcc('x'), wiiControl.getAcc('y'), wiiControl.getAcc('z'));
    
    //println(frameCount);
    //wiiControl.setLeds(false,false,false,false);
  }
}

void mousePressed() {
  wiiControl.rumble(100);
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
