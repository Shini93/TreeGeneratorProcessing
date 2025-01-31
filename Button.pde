
int sizeFont = 20;

/**************************************************
*A generic Button object
*Can be clicked and a function is called if clicked
**************************************************/
class Button {
  int deltaT =0;
  color c = 000000;
  color bgc = #FFFFFF;
  String text = "Button";
  int x = 0;
  int y = sizeFont;
  int boxSizeX = 200;
  int boxSizeY = 30;
  int opacity = 255;
  boolean onlyTextSize = false;
  boolean isSwitch = false;
  boolean isActive = false;
  boolean fired = false;
  boolean isHovered = false;

  void initButton() {
    DrawButton();
  }
  Button(int x1, int y1, String text1) {
    x=x1;
    y=y1+sizeFont;
    text = text1;
    initButton();
  }
  Button(int x1, int y1, int x2, int y2, String text1) {
    x=x1;
    y=y1+sizeFont;
    boxSizeX = x2;
    boxSizeY = y2;
    text = text1;
    initButton();
  }
  Button(int x1, int y1, int x2, int y2, String text1, int opacityy) {
    x=x1;
    opacity = opacityy;
    y=y1+sizeFont;
    boxSizeX = x2;
    boxSizeY = y2;
    text = text1;
    initButton();
  }
  Button(int x1, int y1, String text1, color c1, color bg) {
    x=x1;
    y=y1+sizeFont;
    text = text1;
    c = c1;
    bgc = bg;
    initButton();
  }
  Button(int x1, int y1, String text1, color c1, color bg, int size) {
    x=x1;
    y=y1+sizeFont;
    text = text1;
    c = c1;
    bgc = bg;
    sizeFont = size;
    initButton();
  }
  
  void DrawButton() {
    if (onlyTextSize == true)
      boxSizeX = ceil(textWidth(text));
    noStroke();
    fill(bgc, opacity);
    rect(x, y-boxSizeY+3, boxSizeX, boxSizeY+6);
    fill(c, opacity);
    text(text, x+int(boxSizeX-textWidth(text))/2, y-boxSizeY+25);
  }

  Boolean isFired() {
    fired = false;
    isHovered = false;
    if (mouseX<x)
      return false;
    if (mouseX > x+boxSizeX)
      return false;
    if (mouseY < y-boxSizeY+3)
      return false;
    if (mouseY > y+ 6)
      return false;
    isHovered = true;
    if (mousePressed  == false)
      return false;

    if (deltaT>0)   //Can only be clicked all 200 milliseconds, so that no multiple clicks occur when the fps are too fast
      if (millis()-deltaT < 200) {
        fired = false;
        return false;
      }
    deltaT = millis();
    if (isSwitch == true)
      isActive = !isActive;
    fired = true;
    return true;
  }
}
