boolean lockedGlobal = false;

/**************************************************
*Creates a slider, which can be dragged and it
*creates a return value in a given range.
*Took the code from Daniel Schieffman and added
*Needed extra functions.
**************************************************/
class Slider {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  float loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;
  String name = "";
  PVector range = new PVector(0,1);
  color sColor = #00FF00;
  color bColor = #55AA55;
  color hColor = #00EE00;

  Slider (float xp, float yp, int sw, int sh, int l) {
   init(xp, yp, sw, sh, l);
  }
  
  void setColor(color[] c){
    sColor = c[0];
    bColor = c[1];
    hColor = c[2];
  }
  
  void init(float xp, float yp, int sw, int sh, int l){
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }
  
  Slider(String name, float xp, float yp, int sw, int sh, int l){
    this.name = name;
    init(xp, yp, sw, sh, l);
  }

  void setSliderPos(float perc){  //in percent
      float range = swidth/2 - sheight/2;
      spos = xpos + 2 * perc * range;
      newspos = spos;
  }
  
  void defRange(float min, float max){
    range = new PVector(min,max); 
  }

  boolean update(int textWidth) {
    if (overEvent(textWidth)) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over && lockedGlobal == false) {
      locked = true;
      lockedGlobal = true;
    }
    if (!mousePressed) {
      locked = false;
      lockedGlobal = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2 - textWidth, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      float nLoose = min(loose,abs(newspos - spos));
      spos = spos + (newspos-spos)/nLoose;
    }
    
    return over;
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent(int textWidth) {
    if (mouseX > xpos + textWidth && mouseX < xpos+swidth + textWidth&&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    noStroke();
    fill(bColor);
    rect(xpos, ypos, swidth, sheight);     //background for slider
    if (over || locked) {
      fill(sColor);
    } else {
      fill(color(hColor));
    }
    rect(spos, ypos, sheight, sheight);    //draws movable rect
  }

  /**************************************************
  *Convert spos to be values between
  *0 and the total width of the scrollbar
  **************************************************/
  float getPos() {
    return spos * ratio;
  }
  
  float getPosCalc(){
    int round = round(100 * (((spos - sheight) * ratio) / swidth));
    return (0.01 * round) ; 
  }
  
  float getRangedOutput(){
    return map(getPosCalc(),0,1,range.x,range.y); 
  }
  
}
