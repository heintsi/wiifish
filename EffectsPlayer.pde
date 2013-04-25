interface Player {
  
  //Adds new sample to player.
  public void addSample(String name, String fileName);
  
  //Triggers a sample.
  public void trigger(String sampleName);
 
  /*Triggers a sample and adds a reverb effect to it.
    Reverb value souhould be [0.0, 1.0]. */
  public void triggerWithRewerb(String sampleName, float reverb);  
}

class EffectsPlayer implements Player{
 
 private final int BUF_SIZE = 512;  
  
 private Minim minim;
 private AudioOutput out;
 private Delay delay;
 private Map<String, AudioSample> samples;
 
 //Map samples contains <Sample name, Filename>
 private EffectsPlayer(Minim minim) {
   this.minim = minim;
   this.samples = new HashMap<String, AudioSample>();
 }
 
 private void initDelay() {
   out = minim.getLineOut( Minim.STEREO, 2048 );
   delay = new Delay( 0.6, 0.9, true, false );
 }
 
 private void loadSamples(Map<String, String> samples) {
   Iterator i = samples.entrySet().iterator();
   
   while(i.hasNext()) {
     Map.Entry entry = (Map.Entry)i.next();
     AudioSample sample = minim.loadSample((String)entry.getValue(), BUF_SIZE);
     this.samples.put((String)entry.getKey(), sample);
   }
 }
 
 public void addSample(String name, String fileName) {
   AudioSample sample = minim.loadSample(fileName, BUF_SIZE);
   this.samples.put(name, sample);
 }
 
  public void trigger(String sampleName) {
    samples.get(sampleName).trigger();
  }
  
  public void triggerWithRewerb(String sampleName, float reverb)  {
    
  }
}
