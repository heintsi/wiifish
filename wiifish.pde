/*
Fishing game for Wiimote.
 */

import oscP5.*;
import netP5.*;
import java.util.ArrayList;

static final boolean SMOOTH_ACC = true;

OscP5 oscP5;
NetAddress myRemoteLocation;
int wiiMoteId = -1;

boolean rumble = false;
boolean leds = false;

WiiControl wiiControl;

WiiFishGame gameInstance;



void setup() {
  size(400, 400);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);
  /* send outgoing messages to port 3001 */
  myRemoteLocation = new NetAddress("127.0.0.1", 3001);

  wiiControl = new WiiControl(myRemoteLocation);
}


void draw() {
  background(wiiControl.triggerPressed() ? color(255, 0, 0) : 0);  
  if (wiiControl.getId() > -1) {
    wiiControl.update();

    
    // Middle line
    stroke(126);
    line(0, height/2, width, height/2);
    // Other straight lines
    stroke(64);
    line(0, height/2 - 30, width, height/2 - 30);
    line(0, height/2 + 30, width, height/2 + 30);
    line(0, height/2 - 60, width, height/2 - 60);
    line(0, height/2 + 60, width, height/2 + 60);
    
    

    // acceleration
    
    if (SMOOTH_ACC == false) {
      stroke(color(255, 0, 0));
      drawAccGraph(wiiControl.getAccData('x'));
      
      stroke(color(0, 255, 0));
      drawAccGraph(wiiControl.getAccData('y'));
      
      stroke(color(0, 0, 255));
      drawAccGraph(wiiControl.getAccData('z'));
    } else {
      stroke(color(255, 0, 0));
      drawAccGraph(wiiControl.getSmoothAccData('x'));
      
      stroke(color(0, 255, 0));
      drawAccGraph(wiiControl.getSmoothAccData('y'));
      
      stroke(color(0, 0, 255));
      drawAccGraph(wiiControl.getSmoothAccData('z'));      
    }
  }
  if (gameInstance != null) {
    gameInstance.updateGameState();
  }
}

void drawAccGraph(ArrayList<Float> accData) {
  int K = 1000; // amplification constant
  
  float lastY = height/2;

  for (int i = 1; i < accData.size(); i++) {
    float y = height/2 - accData.get(i).floatValue()*K;
    line(i-1, lastY, i, y);
      
    lastY = y;
  }
}

void mousePressed() {
  wiiControl.fishNibbles((int)Math.random()*5 + 1);
}

void keyPressed() {
  if (keyCode == UP) {
    leds = !leds;
    wiiControl.setLeds(leds, !leds, !leds, leds);
  } else if (keyCode == ENTER) {
    gameInstance = new WiiFishGame(wiiControl);
    gameInstance.startGame();
  }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  wiiControl.oscEvent(theOscMessage);
}

class WiiFishGame {
  
  private WiiController wiimote;
  private boolean running;
  
  public WiiFishGame(WiiController wiimote) {
    this.wiimote = wiimote;
    this.running = false;
  }
  
  public void startGame() {
    this.running = true;
  }
  
  public boolean isRunning() {
    return this.running;
  }
  
  public boolean togglePauseGame() {
    this.running = !this.running;
    return this.isRunning();
  }
  
  public void updateGameState() {
    if (!this.running) return;
    // else update game state, fishnibbles, catch a fish etc.
    
  }
  
  
}
