class FishGame {
  
  private WiiController wiimote;
  private boolean running;
  private boolean baitInWater;
  private boolean fishAtBait;
  private int fishCount;
  
  private float probOfNewFish = 0.002;
  private float probOfNibblesIfFishAtBait = 0.02;
  private float lightPullProbIncr = 0.001;
  
  private long fishAtBaitTimeMillis = 0;
  
  private boolean strongPullDetected;
  private boolean lightPullDetected;
  
  public FishGame(WiiController wiimote) {
    this.wiimote = wiimote;
    this.running = false;
    this.fishCount = 0;
    this.baitInWater = false;
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
      if (this.strongPullDetected) {
        this.baitInWater = false;
        println("No fish!");
        return;
      }
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
    this.running = false;
    this.wiimote.gameWon();
    println("Game finished.");
  }
  
  private void checkIfBaitIsThrown() {
    if (this.wiimote.triggerRelease()) {
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
    if (Math.random() < probOfNibblesIfFishAt
    Bait) this.generateFishNibbles();
    else if (this.fishHasBeenAtBaitForTooLong()) {
      this.fishAtBait = false;
    }
  }
  
  private boolean fishHasBeenAtBaitForTooLong() {
    // the longer the fish has been at the bait, the higher the probability it leaves
    return false;
  }
  
  private void generateFishNibbles() {
    wiimote.fishNibbles(3);
  }
  
  private void generateFish() {
    if (this.lightPullDetected) {
      probOfNewFish += lightPullProbIncr;
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
