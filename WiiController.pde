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
  
  public boolean isReelingComplete();
  
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
  Methods to tell the WiiController a new fish has been caught.
  */
  public void fishCaught();
  public void fishesCaught(int n);
  
  /**
  Method to reset fishing progress.
  */
  public void resetFishing();
  
  /**
  Method to be called when the game has been won.
  */
  public void gameWon();
  
  /**
  Method to be called once per frame
  */
  public void update();
}

public class WiiControl implements WiiController {
  
  private static final boolean DBG = true;
  private static final int SMOOTH_LEVEL = 2;
  
  private int id, nFishCaught;
  private boolean isNew;
  private float calibX, calibY, calibZ, accX, accY, accZ;
  private NetAddress myRemoteLocation;
  private Rumbler rumbler;
  private FireWorks fireWorks;
  private ReelingGestureDetector reelingDetector;
  
  private ArrayList<Float> accXData,accYData,accZData, accXSmooth,accYSmooth,accZSmooth;
  
  private boolean triggerPressed, triggerPressFlag, triggerReleaseFlag;
  private boolean lightPullFlag, strongPullFlag, isThrownFlag;
  private boolean isWon;
  
  private float lastPullMillis;
  
  public WiiControl(NetAddress myRemoteLocation) {
    this.id = -1;
    this.isNew = true;
    
    this.calibX = this.calibY = this.calibZ =
      this.accX = this.accY = this.accZ = 0.0;  
    this.lastPullMillis = 0.0;
    
    this.triggerPressed = 
      this.triggerPressFlag = 
      this.triggerReleaseFlag = 
      this.lightPullFlag =
      this.strongPullFlag =
      this.isThrownFlag = false;
    
    this.myRemoteLocation = myRemoteLocation;
    this.rumbler = new Rumbler();
    this.fireWorks = new FireWorks();
    this.reelingDetector = new ReelingGestureDetector(this);
    
    // lists store accelerator data so that the newest data is at the end
    this.accXData = new ArrayList<Float>();
    this.accYData = new ArrayList<Float>();
    this.accZData = new ArrayList<Float>();
    
    // these lists are used to store smoothed versions of the above
    this.accXSmooth = new ArrayList<Float>();
    this.accYSmooth = new ArrayList<Float>();
    this.accZSmooth = new ArrayList<Float>();
    
    resetFishing();
  }
  
  public void resetFishing() {
    this.nFishCaught = 0;
    this.isWon = false;
    this.fireWorks.stop();
  }
  
  public void fishCaught() {
    this.nFishCaught++;
    if (DBG) println("WiiControl: Fish caught! Total: "+nFishCaught);
    ledUpdate();
  }
  
  public void fishesCaught(int n) {
    this.nFishCaught = n;
    println("WiiControl: Fishes caught: "+nFishCaught);
    ledUpdate();
  }
  
  public void gameWon() {
    this.isWon = true;
    rumbler.rumbleOnce(1500);
    if (DBG) println("WiiControl: game won!");
  }
  
  public void printAcc() {
    System.out.printf("x: %f, y: %f, z: %f\n", accX, accY, accZ);
  }
  
  public void oscEvent(OscMessage theOscMessage) {
    // Wiimote found, typetag "i"
    if (theOscMessage.checkAddrPattern("/wii/found")) {
      this.found(theOscMessage.get(0).intValue());
      println("***WII FOUND***");
    }
    // Accelerometer update, typetag "if"
    else if (theOscMessage.addrPattern().contains("/wii/acc")) {
      String which = theOscMessage.addrPattern().split("/")[3];
      char whichC = which.toCharArray()[0];
      float accVal = 0.0;
      if(theOscMessage.get(1) == null) {
        accVal = theOscMessage.get(0).floatValue();
      } else {
        accVal = theOscMessage.get(1).floatValue();
      }
      float diff = Math.abs(this.getAcc(whichC) - accVal);
      if (diff > 0.05) {
        //println("big change in acc: "+which+" ("+diff+")");
      }
      
      this.setAcc(whichC, accVal);
    }
    
    // Buttons
    else if (theOscMessage.addrPattern().contains("/wii/keys")) {
      String which = theOscMessage.addrPattern().split("/")[3];
      
      // The trigger, namely B-button
      if (which.equals("b")) {
        
        if (theOscMessage.get(0).intValue() == 1) { // down
          if (DBG) println(">> Trigger pressed @ "+millis());
          this.triggerPressFlag = true;
          this.triggerPressed = true;
        } else { // up
          if(this.triggerPressed) {
            if (DBG) println(">> Trigger released @ "+millis());
            this.triggerReleaseFlag = true;
            this.triggerPressed = false;
          }
        }
      }
    }
  }
  
  public void update() {
    
    // if we have data to cover the whole screen, remove the oldest
    while (accXData.size() > width)
      accXData.remove(0);
    while (accYData.size() > width)
      accYData.remove(0);
    while (accZData.size() > width)
      accZData.remove(0);
    
    // update smoothed versions
    if (this.accXData.size() > SMOOTH_LEVEL) {
      float sum = 0.0;
      for (int i = 0; i < SMOOTH_LEVEL; i++) {
        sum += this.accXData.get(this.accXData.size()-1-i);
      }
      float mean = sum / (SMOOTH_LEVEL+1);
      this.accXSmooth.add(mean);
    }
    if (this.accYData.size() > SMOOTH_LEVEL) {
      float sum = 0.0;
      for (int i = 0; i < SMOOTH_LEVEL; i++) {
        sum += this.accYData.get(this.accYData.size()-1-i);
      }
      float mean = sum / (SMOOTH_LEVEL+1);
      this.accYSmooth.add(mean);
    }
    if (this.accZData.size() > SMOOTH_LEVEL) {
      float sum = 0.0;
      for (int i = 0; i < SMOOTH_LEVEL; i++) {
        sum += this.accZData.get(this.accZData.size()-1-i);
      }
      float mean = sum / (SMOOTH_LEVEL+1);
      this.accZSmooth.add(mean);
    }
    while (this.accXSmooth.size() > width)
      this.accXSmooth.remove(0);
    while (this.accYSmooth.size() > width)
      this.accYSmooth.remove(0);
    while (this.accZSmooth.size() > width)
      this.accZSmooth.remove(0);
    
    
    if (isWon) {
      if (!fireWorks.isRunning()) fireWorks.start();
      fireWorks.update();
    } else {
      testStrongPull();
      testLightPull();
      reelingDetector.testReeling();
    }
    
    
    // rumbler
    rumbler.update();
    
  }
  
  private void ledUpdate() {
    // show the number of fish caught using the leds
    int n = this.nFishCaught;
    if (n == 0) {
      this.setLeds(false,false,false,false);
    } else {
      this.setLeds(
        n%4 >= 1 || n%4 == 0,
        n%4 >= 2 || n%4 == 0,
        n%4 >= 3 || n%4 == 0,
        n%4 == 0);
    }  
  }
  
  private float getAcc(char c) {
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

  
  private void found(int id) {
    if (DBG) println("NEW mote id: "+id);
    this.id = id;
    this.setLeds(false,false,false,false);
  }
  public int getId() {
    return id;
  }
  
  public void setAcc(char c, float val) {
    switch (c) {
      case 'x':
        if (calibX == 0.0) calibX = val;
        accX = calibX - val;
        accXData.add(accX);
        break;
      case 'y':
        if (calibY == 0.0) calibY = val;
        accY = calibY - val;
        accYData.add(accY);
        break;
      case 'z':
        if (calibZ == 0.0) calibZ = val;
        accZ = calibZ - val;
        accZData.add(accZ);
        break;
    }
  }
  public ArrayList<Float> getAccData(char c) {
    switch (c) {
      case 'x':
        return this.accXData;
      case 'y':
        return this.accYData;
      case 'z':
        return this.accZData;
      default:
        return null;
    }
  }
  
  public ArrayList<Float> getSmoothAccData(char c) {
    switch (c) {
      case 'x':
        return this.accXSmooth;
      case 'y':
        return this.accYSmooth;
      case 'z':
        return this.accZSmooth;
      default:
        return null;
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
    return this.reelingDetector.isReelingStarted();
  }
  
   public boolean isReelingComplete() {
    return this.reelingDetector.isReelingComplete();
  }
  
  public boolean lightPull() {
    if (lightPullFlag) {
      lightPullFlag = false;
      return true;
    }
    
    return false;
  }

  public boolean strongPull() {
    if (strongPullFlag) {
      strongPullFlag = false;
      return true;
    }
    
    return false;
  }
  
  public void fishNibbles(int nTimes) {
    rumbler.doRandomRumbles(nTimes);
  }
  
  
  ////// Gesture test methods
  
  private void testLightPull() {
    
    int datapoints = 10;
    float threshold = 0.03;
    
    if(genericPull(datapoints, threshold)) {
      println("  -> light pull @ "+millis());
      lightPullFlag = true;
    }
  }
  
  private void testStrongPull() {
    
    int datapoints = 15;
    float threshold = 0.06;
    
    if(genericPull(datapoints, threshold)) {
      println("  ---> STRONG PULL @ "+millis());
      strongPullFlag = true;
    }
  }
  
  private boolean genericPull(int datapoints, float threshold) {
    // this is how much the pulls need to be apart
    int waitMillis = 500;
    
    if (millis() < lastPullMillis+waitMillis)
      return false;
    
    
    // avoid ArrayIndexOutOfBounds
    if (accZSmooth.size() < datapoints) {
      return false;
    }
    
    float[] data = new float[datapoints];
    for (int i = 0; i < datapoints; i++) {
      int listI = accZSmooth.size()-datapoints+i;
      data[i] = accZSmooth.get(listI).floatValue();
    }
    
    int downPeakIdx = -1;
    int upPeakIdx = -1;
    
    // go through the last accZ datapoints to see if the 
    // acceleration has changed down and up severely 
    
    for (int i = 0; i < datapoints; i++) {
      if (-data[i] > threshold) {
        downPeakIdx = i;
        break;
      }
    }
    if (downPeakIdx < 0)
      return false;
    for (int i = downPeakIdx; i < datapoints; i++) {
      if (data[i] > threshold) {
        upPeakIdx = i;
        break;
      }
    }
    
    if (downPeakIdx > 0 && upPeakIdx > 0) {
      lastPullMillis = millis();
      return true;
    } else {
      return false;
    }
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
  Helper class for the fireworks.
  */
  class FireWorks {
    private static final int FRAMES_PER_CYCLE = 15;
    
    private boolean led1,led2,led3,led4;
    private int startFrame;
    
    FireWorks() {
      this.led1 = this.led2 = this.led3 = this.led4 = false;
      this.startFrame = -1;
    }
    
    boolean isRunning() {
      return (this.startFrame == -1 ? false : true);
    }
    
    void start() {
      this.startFrame = frameCount;
      if (DBG) println("FireWorks started @ "+millis());
    }
    
    void stop() {
      this.startFrame = -1;
    }
    
    void update() {
      if (this.isRunning()) {
        if ( (frameCount-startFrame) % FRAMES_PER_CYCLE == 0) {
          float p = 0.35;
          WiiControl.this.setLeds(
            Math.random() < p,
            Math.random() < p+0.1,
            Math.random() < p+0.1,
            Math.random() < p);
        }
      }
    }
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
    
    void rumbleOnce(int millis) {
      this.n = 0;
      this.maxN = 1;
      this.rumbleStartMillis[0] = millis();
      this.rumbleStopMillis[1] = millis()+millis;
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
