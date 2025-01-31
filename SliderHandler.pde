/**************************************************
*Calculates and draws all slider
*Checks which sliders are interacted with
**************************************************/
class SliderHandler {
  ArrayList <Slider> sliders = new ArrayList <Slider>();
  ArrayList <Button> buttons = new ArrayList <Button>();
  int sWidth = 300;
  int sHeight = 20;
  int sPosX = 20;
  int sAbstand = 10;
  int sSlow = 10;
  int textWidth = 10;
  private int rangedOutput = 0;

  int green = 0;
  int red = 1;
  int blue = 2;

  boolean isOver = false;

  color[] sColor = {#00FF00, #FF0000, #0000FF, #FFFF00, #FF00FF, #00FFFF};
  color[] bColor = {#55AA55, #AA5555, #5555AA, #AAAA55, #AA55AA, #55AAAA};
  color[] hColor = {#00EE00, #EE0000, #0000EE, #EEEE00, #EE00EE, #00EEEE};

  SliderHandler() {
  }

  void setColor(int s, int c) {
    color[] col = {sColor[c], bColor[c], hColor[c]};
    sliders.get(s).setColor(col);
  }
  
  void setColor(int c){
    setColor(sliders.size()-1,c); 
  }
  
  void setColor(String name, int c){
    setColor(getSlider(name),c); 
  }

  void setSliderPosAll(float perc) {
    for (Slider s : sliders) {
      s.setSliderPos(perc);
    }
  }

  void setSliderPos(int s, float perc) {
    sliders.get(s).setSliderPos(perc);
  }
  
  void setSliderPos(float perc) {
    setSliderPos(sliders.size()-1,perc);
  }
  
   void setSliderPos(String name, float perc) {
    setSliderPos(getSlider(name),perc);
  }

  int getSlider(String name){
    for(int s = 0; s < sliders.size(); s++){
       if(sliders.get(s).name == name)
         return s;
    }
    return -1;
  }

  void addSlider() {
    sliders.add(new Slider ("Slider "+(sliders.size()+1), sPosX, (sliders.size() + 1) * sAbstand, sWidth, sHeight, sSlow));
    textWidth = max(ceil(textWidth(sliders.get(sliders.size()-1).name)), textWidth);

    buttons.add(new Button(sPosX, round((sliders.size() -0.5) * sAbstand), round(textWidth("Slider "+(sliders.size()+1))), sHeight, "Slider "+(sliders.size()+1), 0));
    buttons.get(buttons.size()-1).onlyTextSize = true;
    buttons.get(buttons.size()-1).isSwitch = true;
  }

  void addSlider(String name) {
    sliders.add(new Slider (name, sPosX, (sliders.size() + 1) * sAbstand, sWidth, sHeight, sSlow));
    textWidth = max(ceil(textWidth(name)), textWidth);
    buttons.add(new Button(sPosX, round((sliders.size() -0.5) * sAbstand), round(textWidth(name)), sHeight, name, 0));
    buttons.get(buttons.size()-1).onlyTextSize = true;
    buttons.get(buttons.size()-1).isSwitch = true;
  }

  void addSlider(String name, float min, float max, float init, int col) {
    sliders.add(new Slider (name, sPosX, (sliders.size() + 1) * sAbstand, sWidth, sHeight, sSlow));
    buttons.add(new Button(sPosX, round((sliders.size() -0.5) * sAbstand), round(textWidth(name)), sHeight, name, 0));
    buttons.get(buttons.size()-1).onlyTextSize = true;
    buttons.get(buttons.size()-1).isSwitch = true;
    sliders.get(sliders.size()-1).defRange(min, max);
    sliders.get(sliders.size()-1).setSliderPos(init);
    setColor(sliders.size()-1, col);
    textWidth = max(ceil(textWidth(name)), textWidth);
  }

  void drawSlider() {
    for (int s = 0; s < sliders.size(); s++)
      sliders.get(s).display();
  }

  int updateSlider(int textWidth) {
    isOver = false;
    for (int s = 0; s < sliders.size(); s++) {
      isOver = sliders.get(s).update(textWidth);
      if (isOver == true)
        return s;
    }
    return 0;
  }

  int drawAndUpdateSlider() {
    int out = updateSlider(textWidth);
    if (lockedGlobal == true && (out == 25 || out== 26|| out == 24 || out == 23)) {
      PVector sun = new PVector(sunPos.x*tG.width, sunPos.y*tG.height);
      setLight(sun, 0.001*sunIntensity*sqrt(tG.width*tG.width+tG.height*tG.height));
      wasResized = true;
      println("------------------light---------------");
    }
    else if (lockedGlobal == true && (out == 22 || out== 21|| out == 20 )) {
    }
    pushMatrix();
    translate(textWidth, 0);
    drawValues();
    drawSlider();
    popMatrix();
    drawText();
    updateButtons();
    return out;
  }

  int updateButtons() {
    for (int b = 0; b < buttons.size(); b++) {
      buttons.get(b).DrawButton();
      if (buttons.get(b).isFired()) {
        return b;
      }
    }
    return -1;
  }

  void drawValues() {
    fill(125);
    noStroke();
    if (sHeight != g.textSize)
      textWidth = round(textWidth*(sHeight/g.textSize));
    //textSize(sHeight);
    rect(sPosX + sWidth, 20, sHeight * 5, (sliders.size() - 1) * sAbstand + sHeight);
    fill(0);
    for (int s = 0; s < sliders.size(); s++) {
      float xPercent = sliders.get(s).getPosCalc();
      float out = sliders.get(s).getRangedOutput();
      
      text(nf(out,0,2), sPosX + sWidth, sliders.get(s).ypos + sAbstand/2);
    }
  }

  void drawText() {
    fill(125);
    noStroke();
    rect(sPosX, 20, textWidth, (sliders.size() - 1) * sAbstand + sHeight);
    fill(0);
    for (int s = 0; s < sliders.size(); s++) {
      text(s + "  "+sliders.get(s).name, sPosX, sliders.get(s).ypos + sAbstand/2);
    }
  }

  void printSliderConfig() {
    println("xPos: "+sPosX + "  yPos: "+sAbstand+ "  xWidth: "+sWidth+ "  yHeight: "+sHeight+ " trägheit: "+ sSlow);
    for (int s = 0; s < sliders.size(); s++) {
      println("sliders.add(new Slider (\"" + sliders.get(s).name+"\", "+sPosX+", "+sliders.get(s).ypos+", "+sWidth+", "+sHeight+", "+sSlow+"));");
    }
  }

  void changeParameter(char k) {
    if (k == '+')
      sWidth+=20;
    if (k == '-')
      sWidth-=20;
    updateParameter();
  }

  void updateParameter() {
    int size = sliders.size();
    sliders.clear();
    for (int s = 0; s < size; s++)
      addSlider();
    background(125);
  }

  float getPerc(int number) {
    return sliders.get(number).getPosCalc();
  }
  
  float getPerc(String name){
    return getPerc(getSlider(name)); 
  }

  float getRangedOutput(int number) {
    return map(getPerc(number), 0, 1, sliders.get(number).range.x, sliders.get(number).range.y);
  }
  
  float getRangedOutput(String name){
    return getRangedOutput(getSlider(name));
  }
  
  float getRangedOutput(){
    float out = getRangedOutput(rangedOutput); 
    rangedOutput = (rangedOutput + 1) % sliders.size();
    return out;
  }

  void defRange(int number, float min, float max) {
    sliders.get(number).range = new PVector(min, max);
  }
  
  void defRange(String name, float min, float max){
    defRange(getSlider(name),min,max); 
  }
  
  void defRange(float min, float max){
    defRange(sliders.size()-1,min,max); 
  }
}
