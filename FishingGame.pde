class FishGame {
  
  private WiiController wiimote;
  private boolean running;
  private boolean baitInWater;
  private boolean fishAtBait;
  private int fishCount;
  
  private float probOfNewFish = 0.002;
  
  private boolean strongPullDetected;
  private boolean lightPullDetected;
  
  public FishGame(WiiController wiimote) {
    this.wiimote = wiimote;
    this.running = false;
    this.fishCount = 0;
    this.baitInWater = true; // change to false when "isThrown" is implemented
    this.fishAtBait = false;
    
    this.strongPullDetected = false;
    this.lightPullDetected = false;
    println("Game created.");
  }
  
  public void startGame() {
    this.running = true;
    println("Game started.");
  }
  
  public void updateGameState() {
     this.strongPullDetected = wiimote.strongPull();
     this.lightPullDetected = wiimote.lightPull();
    
    if (!this.isRunning()) return;
    // else update game state, fishnibbles, catch a fish etc.
    if (this.isAllowedToFinish()) {
      this.finishGame();
      return;
    }
    if (!this.baitInWater) {
      checkIfBaitIsThrown();
      return;
    }
    if (this.fishAtBait) {
      if (this.strongPullDetected) {
        this.fishCaught();
      }
      this.updateFishAtBait();
    } else {
      this.generateFish();
    }
  }
  
  public boolean isRunning() {
    return this.running;
  }
  
  private boolean isAllowedToFinish() {
    if (this.fishCount < 4)
      return false;
    return true;
  }
  
  private void finishGame() {
    // rumble, flash lights, play sounds
    this.running = false;
    println("Game finished.");
  }
  
  private void checkIfBaitIsThrown() {
    if (this.wiimote.isThrown() && this.wiimote.triggerPressed()) {
      this.baitInWater = true;
      println("Game: Bait thrown.");
    }
  }
  
  private void fishCaught() {
    this.fishAtBait = false;
    this.baitInWater = false;
    this.fishCount++;
    println("Game: Caught fish!");
    wiimote.fishesCaught(fishCount);
  }
  
  private void updateFishAtBait() {
    
    if (Math.random() > 0.95) this.generateFishNibbles();
  }
  
  private void generateFishNibbles() {
    wiimote.fishNibbles(3);
  }
  
  private void generateFish() {
    if (this.lightPullDetected) {
      probOfNewFish += 0.002;
    }
    if (Math.random() < probOfNewFish) {
      this.fishAtBait = true;
      println("Game: Fish at bait!!!");
    }
  }
  
  public boolean togglePauseGame() {
    this.running = !this.running;
    println("Game " + (this.running ? "running." : "paused."));
    return this.isRunning();
  }
  
  
}
