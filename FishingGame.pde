class FishGame {
  
  private WiiController wiimote;
  private EffectsPlayer ePlayer;
  private boolean running;
  private boolean baitInWater;
  private boolean fishAtBait;
  private int fishCount;
  
  private static final float PROB_OF_NEW_FISH_MIN = 0.002;
  private static final float PROB_OF_NEW_FISH_MAX = 0.006;
  private float probOfNewFish = PROB_OF_NEW_FISH_MIN;
  private float probOfNibblesIfFishAtBait = 0.02;
  private float lightPullProbIncr = 0.001;
  
  private long fishAtBaitArrivalTimeMillis = 0;
  private long lastLightPullTimeMillis = 0;
  
  private boolean strongPullDetected;
  private boolean lightPullDetected;
  
  public FishGame(WiiController wiimote, EffectsPlayer ePlayer) {
    this.wiimote = wiimote;
    this.ePlayer = ePlayer;
    
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
        println("Game: No fish!");
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
      this.ePlayer.trigger("FLOAT");
      println("Game: Bait thrown.");
    }
  }
  
  private void fishCaught() {
    this.fishAtBait = false;
    this.baitInWater = false;
    this.fishCount++;
    this.ePlayer.trigger("FISH_SPLASH");
    println("Game: Caught fish!");
    wiimote.fishesCaught(fishCount);
  }
  
  private void updateFishAtBait() {
    if (Math.random() < probOfNibblesIfFishAtBait) this.generateFishNibbles();
    else if (this.fishHasBeenAtBaitForTooLong()) {
      this.fishAtBait = false;
      println("game: Fish left bait!");
    }
  }
  
  private boolean fishHasBeenAtBaitForTooLong() {
    // the longer the fish has been at the bait, the higher the probability it leaves
    long fishAtBaitTime = millis() - this.fishAtBaitArrivalTimeMillis;
    return fishAtBaitTime > 500 && Math.random() < fishAtBaitTime / 8000;
  }
  
  private void generateFishNibbles() {
    wiimote.fishNibbles(3);
  }
  
  private void generateFish() {
    if (this.lightPullDetected) {
      this.increaseFishProbability();
      this.lastLightPullTimeMillis = millis();
    } else {
      this.decreaseFishProbability();
    }
    if (this.enoughTimeFromLastLightPullPassed() && Math.random() < probOfNewFish) {
      this.fishAtBait = true;
      this.fishAtBaitArrivalTimeMillis = millis();
      println("Game: Fish at bait!!!");
    }
  }
  
  private void increaseFishProbability() {
    if (this.probOfNewFish < PROB_OF_NEW_FISH_MAX) this.probOfNewFish += this.lightPullProbIncr;
  }
  
  private void decreaseFishProbability() {
    long diff = millis() - this.lastLightPullTimeMillis;
    if (diff > 1000 && this.probOfNewFish > PROB_OF_NEW_FISH_MIN) {
      this.probOfNewFish -= this.lightPullProbIncr/100;
    }
  }
  
  private boolean enoughTimeFromLastLightPullPassed() {
    return millis() - this.lastLightPullTimeMillis > 1000;
  }
  
  public boolean togglePauseGame() {
    this.running = !this.running;
    println("Game " + (this.running ? "running." : "paused."));
    return this.isRunning();
  }
  
  
}
