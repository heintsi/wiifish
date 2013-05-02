class ReelingGestureDetector {
 
 private WiiControl wii;
 FFT fftZ, fftX;
 
 private boolean isReeling;
 private int framesReeled;
 private int reelFrameBuffer;
 private final int BUFFER_SIZE = 5;
 private final int REEL_DURATION = 50;
 
 public ReelingGestureDetector(WiiControl wii) {
   this.wii = wii;
   this.fftZ = new FFT(64, 50);
   this.fftX = new FFT(64, 50);
   this.framesReeled = 0;
   this.reelFrameBuffer = BUFFER_SIZE;
 } 

 public void testReeling() {
    
    int datapoints = 64;
    ArrayList<Float> accZSmooth = this.wii.getSmoothAccData('z');
    ArrayList<Float> accXSmooth = this.wii.getSmoothAccData('x');
    
    // avoid ArrayIndexOutOfBounds
    if (accZSmooth.size() < datapoints) {
      return;
    }
    
    float[] dataZ = new float[datapoints];
    for (int i = 0; i < datapoints; i++) {
      int listI = accZSmooth.size()-datapoints+i;
      dataZ[i] = accZSmooth.get(listI).floatValue();
    }
    
    float[] dataX = new float[datapoints];
    for (int i = 0; i < datapoints; i++) {
      int listI = accXSmooth.size()-datapoints+i;
      dataX[i] = accXSmooth.get(listI).floatValue();
    }
    
    fftZ.forward(dataZ);
    fftX.forward(dataX);
    
    float highestZ = 0.0;
    float sumZ = 0.0;
    for(int i = 1; i < fftZ.specSize(); i++)
    {
      float zBand = fftZ.getBand(i);
      sumZ += zBand;
      if(zBand > highestZ) highestZ = zBand;
    }
    
    float highestX = 0.0;
    float sumX = 0.0;
    for(int i = 1; i < fftX.specSize(); i++)
    {
      float xBand = fftX.getBand(i);
      sumX += xBand;
      if(xBand > highestX) highestX = xBand;
    }
    
    float avgX = sumX/fftX.specSize();
    float avgZ = sumZ/fftZ.specSize();
    
    float diffX = highestX - avgX;
    float diffZ = highestZ - avgZ;
    
    //println("Diff X: " + diffX + " Diff Z: " + diffZ); 
    
    if(diffX > 0.7 && diffZ > 1.0) {
      this.framesReeled ++;
      this.reelFrameBuffer = this.BUFFER_SIZE;
      
    } else {
      if( this.reelFrameBuffer > 0) {
        this.reelFrameBuffer--;
      } else {
        this.framesReeled = 0;
      }
    }
    if(framesReeled > 0) println(">>> FRAMES " + framesReeled);    
  }
  
  public boolean isReelingStarted() {
   return framesReeled > 0;
  }
  
  public boolean isReelingComplete() {
    return framesReeled >= REEL_DURATION;
  }

}
