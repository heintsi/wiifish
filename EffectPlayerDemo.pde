import ddf.minim.*;
import ddf.minim.ugens.*;
import java.util.Map;
import java.util.Iterator;

EffectsPlayer ePlayer;

void setup()
{
  size(512, 200, P3D);
  
  ePlayer = new EffectsPlayer(new Minim(this));
  ePlayer.addSample("FLOAT", "tiny-splash.wav");
  ePlayer.addSample("FISH_SPLASH", "water-splashing.wav");
  ePlayer.addSample("REEL", "fishing-reel.aif");
}

void draw()
{
  background(0);
  stroke(255);
}

void keyPressed() 
{
  if ( key == 'a' ) ePlayer.trigger("FLOAT");
  if ( key == 's' ) ePlayer.trigger("FISH_SPLASH");
  if ( key == 'd' ) ePlayer.trigger("REEL");
}
