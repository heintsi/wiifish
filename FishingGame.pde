class FishGame {
  
  private WiiController wiimote;
  private boolean running;
  
  public FishGame(WiiController wiimote) {
    this.wiimote = wiimote;
    this.running = false;
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
  
  public boolean togglePauseGame() {
    this.running = !this.running;
    println("Game " + (this.running ? "running." : "paused."));
    return this.isRunning();
  }
  
  
}
