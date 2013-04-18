class FishGame {
  
  private WiiController wiimote;
  private boolean running;
  private boolean baitInWater;
  private boolean fishAtBait;
  
  private float probOfNewFish = 0.1;
  
  public FishGame(WiiController wiimote) {
    this.wiimote = wiimote;
    this.running = false;
    this.baitInWater = false;
    this.fishAtBait = false;
    println("Game created.");
  }
  
  public void startGame() {
    this.running = true;
    println("Game started.");
  }
  
  public void updateGameState() {
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
      if (wiimote.strongPull()) {
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
    return false;
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
    println("Game: Caught fish!");
  }
  
  private void updateFishAtBait() {
    
    
    this.generateFishNibbles();
  }
  
  private void generateFishNibbles() {
    
  }
  
  private void generateFish() {
    if (wiimote.lightPull()) {
      probOfNewFish += 0.1;
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
