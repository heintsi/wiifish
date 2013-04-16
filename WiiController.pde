interface WiiController {
  
  /**
  Tells a new Wiimote has been found.
  */
  public int wiimoteFound();
  
  /**
  Tells whether the trigger is being pressed right now.
  */
  public boolean triggerPressed();
  
  /**
  Event telling the trigger has just been pressed. 
  */
  public boolean triggerPress();
  
  /**
  Event telling the trigger has just been released. 
  */
  public boolean triggerRelease();
  
  
  /**
  Tells whether the user is "reeling" right now.
  */
  public boolean isReeling();
  
  /**
  Event telling a light pull has been made.
  */
  public boolean lightPull();
  
  /**
  Event telling a strong pull has been made.
  */
  public boolean strongPull();
  
  /**
  Event telling a throw has been made.
  */
  public boolean isThrown();
  
  /**
  Method for invoking a series of rumbles, telling a fish is nibbling.
  @param nTimes how many rumbles to give
  */
  public void fishNibbles(int nTimes);
  
  /**
  Method to be called once per frame
  */
  public void update();
}

public class WiiControl implements WiiController {
  
  private int id;
  private boolean isNew;
  private float accX, accY, accZ;
  private NetAddress myRemoteLocation;
  private Rumbler rumbler;
  
  private boolean triggerPressed, triggerPressFlag, triggerReleaseFlag;
  
  public WiiControl(NetAddress myRemoteLocation) {
    this.id = -1;
    this.isNew = true;
    this.accX = this.accY = this.accZ = 0.0;
    this.triggerPressed = 
      this.triggerPressFlag = 
      this.triggerReleaseFlag = false;
    
    this.myRemoteLocation = myRemoteLocation;
    this.rumbler = new Rumbler();
  }
  
  public void oscEvent(OscMessage theOscMessage) {
    // Wiimote found, typetag "i"
    if (theOscMessage.checkAddrPattern("/wii/found")) {
      this.setId(theOscMessage.get(0).intValue());
    }
    // Accelerometer update, typetag "if"
    else if (theOscMessage.addrPattern().contains("/wii/acc")) {
      String which = theOscMessage.addrPattern().split("/")[3];
      char whichC = which.toCharArray()[0];
      this.setAcc(whichC, theOscMessage.get(1).floatValue());
    }
    
    // Buttons
    else if (theOscMessage.addrPattern().contains("/wii/keys")) {
      String which = theOscMessage.addrPattern().split("/")[3];
      if (which.equals("b")) {
        if (theOscMessage.get(1).intValue() == 1) {
          println(">> Trigger pressed @ "+millis());
          this.triggerPressFlag = true;
          this.triggerPressed = true;
        } else {
          println(">> Trigger released @ "+millis());
          this.triggerReleaseFlag = true;
          this.triggerPressed = false;
        }
      }
    }
  }
  
  public void update() {
    // rumble
    rumbler.update();
  }
  
  public void setId(int id) {
    println("NEW mote id: "+id);
    this.id = id;
  }
  public int getId() {
    return id;
  }
  
  public void setAcc(char c, float val) {
    switch (c) {
      case 'x':
        this.accX = val;
        break;
      case 'y':
        this.accY = val;
        break;
      case 'z':
        this.accZ = val;
        break;
    }
  }
  public float getAcc(char c) {
    switch (c) {
      case 'x':
        return this.accX;
      case 'y':
        return this.accY;
      case 'z':
        return this.accZ;
      default:
        return 0.0;
    }
  }
  
  public int wiimoteFound() {
    if (isNew && id != -1) {
      this.isNew = false;
      return id;
    } else {
      return -1;
    }
  }
  
  public boolean triggerPressed() {
    return triggerPressed;
  }
  
  public boolean triggerPress() {
    if (triggerPressFlag) {
      triggerPressFlag = false;
      return true;
    }
    
    return false;
  }
  
  public boolean triggerRelease() {
    if (triggerReleaseFlag) {
      triggerReleaseFlag = false;
      return true;
    }
    
    return false;
  }
  
  public boolean isThrown() {
    return false;
  }
  
  public boolean isReeling() {
    return false;
  }
  
  public boolean lightPull() {
    return false;
  }

  public boolean strongPull() {
    return false;
  }
  
  public void fishNibbles(int nTimes) {
    rumbler.doRandomRumbles(nTimes);
  }
  
  


  ////// Private methods to more directly use hardware functions
  
  
  private void setLeds(boolean led1, boolean led2, boolean led3, boolean led4) {
    OscMessage myMessage = new OscMessage("/wii/leds");
  
    myMessage.add(this.getId()); /* add the ID the osc message */
    
    myMessage.add(led1 ? 1 : 0);
    myMessage.add(led2 ? 1 : 0);
    myMessage.add(led3 ? 1 : 0);
    myMessage.add(led4 ? 1 : 0);
  
    /* send the message */
    oscP5.send(myMessage, myRemoteLocation); 
  }
  
  /**
  Helper class to do all the rumbling.
  */
  class Rumbler {
    
    private int n, maxN;
    private int[] rumbleStartMillis;
    private int[] rumbleStopMillis;
    
    private boolean isRumbling;
    
    Rumbler() {
      this.n = 0;
      this.rumbleStartMillis = new int[64];
      this.rumbleStopMillis = new int[64];
      this.isRumbling = false;
    }
    
    
    /**
    Does rumbles nTimes in succession.
    For each rumble, a pause follows.
    */
    void doRandomRumbles(int nTimes) {
      this.n = 0;
      this.maxN = nTimes-1;
      
      // Rumble lengths alternate with pause lengths
      
      int lastMillis = millis();
      
      for (int i = 0; i < nTimes; i++) {
        // Rumble 100-150 ms
        this.rumbleStartMillis[i] = lastMillis + (int)(100 + Math.random()*50);
        lastMillis = this.rumbleStartMillis[i];
        
        // Pause 50-80 ms
        this.rumbleStopMillis[i] = lastMillis + (int)(50 + Math.random()*30);
        lastMillis = this.rumbleStopMillis[i];
      }
      this.update();
    }
    
    void update() {
      if (n <= maxN) {
        if (isRumbling) {
          if (rumbleStopMillis[n] < millis()) {
            setRumble(false);
            
            // This rumble cycle is done, increase n.
            n++;
          }
        } else {
          if (rumbleStartMillis[n] < millis()) {
            setRumble(true);
          }
        }
      }
    }
    
    private void setRumble(boolean rumbling) {
      this.isRumbling = rumbling;
      
      OscMessage myMessage = new OscMessage("/wii/rumble");
      
      myMessage.add(wiiControl.getId()); /* add an int to the osc message */
      myMessage.add(rumbling ? 1 : 0);
    
      /* send the message */
      oscP5.send(myMessage, myRemoteLocation); 
    }
  }

}
