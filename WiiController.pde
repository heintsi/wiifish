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
  Method to be called once per frame
  */
  public void update();
}

public class WiiControl implements WiiController {
  
  private int id;
  private boolean isNew;
  private float accX, accY, accZ;
  private NetAddress myRemoteLocation;
  
  private int rumbleOffMillis;
  private boolean isRumbleOn;
  private boolean triggerPressed;
  
  public WiiControl(NetAddress myRemoteLocation) {
    this.id = -1;
    this.isNew = true;
    this.accX = this.accY = this.accZ = 0.0;
    
    this.myRemoteLocation = myRemoteLocation;
    
    this.isRumbleOn = this.triggerPressed = false;
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
          this.triggerPressed = true;
        } else {
          println(">> Trigger released @ "+millis());
        }
      }
    }
  }
  
  public void update() {
    // rumble
    if (isRumbleOn && rumbleOffMillis <= millis()) {
      setRumble(false);
      println("    Rumble over.");
    }
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
    if (triggerPressed) {
      triggerPressed = false;
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
  
  public void setRumble(boolean on) {
    isRumbleOn = on;
    
    OscMessage myMessage = new OscMessage("/wii/rumble");
    
    myMessage.add(wiiControl.getId()); /* add an int to the osc message */
    myMessage.add(on ? 1 : 0);
  
    /* send the message */
    oscP5.send(myMessage, myRemoteLocation); 
  }
  
  public void rumble(int millis) {
    this.rumbleOffMillis = millis()+millis;
    println("!!! Rumble: "+millis);
    this.setRumble(true);
  }

  public void setLeds(boolean led1, boolean led2, boolean led3, boolean led4) {
    OscMessage myMessage = new OscMessage("/wii/leds");
  
    myMessage.add(this.getId()); /* add the ID the osc message */
    
    myMessage.add(led1 ? 1 : 0);
    myMessage.add(led2 ? 1 : 0);
    myMessage.add(led3 ? 1 : 0);
    myMessage.add(led4 ? 1 : 0);
  
    /* send the message */
    oscP5.send(myMessage, myRemoteLocation); 
  }
}
