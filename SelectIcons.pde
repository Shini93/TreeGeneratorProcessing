/**************************************************
*Icons can be clicked and selected, or unselected.
*They are just buttons with extra highliting
**************************************************/
class SelectIcon{
  String folder;
  PVector pos;
  PVector size;
  ArrayList <PImage> icons = new ArrayList <PImage>();
  ArrayList <Button> button = new ArrayList <Button>();
  int usedIcon = -1;
  boolean visible = true;
  
  SelectIcon(String folder,PVector pos, PVector size){
    this.folder = folder;
    this.pos = pos;
    this.size = size;
  }
  
  SelectIcon(String folder, int posX, int posY, int sizeX, int sizeY){
    this.folder = folder;
    pos = new PVector(posX,posY);
    size = new PVector(sizeX,sizeY);
  }
  
  void addIcon(String name){
    PImage dummy = loadImage(folder+"/"+name+".png");
    icons.add(dummy);
  }
  
  void drawIcon(){ //<>// //<>// //<>//
    if(visible == false)
      return;
    int Abstand = round( 0.1* (size.x / float (icons.size())));
    if(usedIcon >= 0){
      fill(#AAFFAA);
      rect(pos.x + size.x * (float(usedIcon) / float(icons.size()+1)) + Abstand * usedIcon - 0.5 * Abstand, pos.y + size.y - 0.5 * Abstand , size.x / icons.size() - 0.5*Abstand, size.y + Abstand);
    }
    for(int i = 0; i < icons.size(); i++){
      float dx = size.x * (float(i) / float(icons.size()+1));
      image(icons.get(i),pos.x + dx + Abstand * i,pos.y+size.y,size.x/(icons.size()+1),size.y);
    }
  }
  
  int checkFeedback(){
    if(visible == false)
      return -1;
     for(int i = 0; i < icons.size(); i++){
      int Abstand = round( 0.1* (size.x / float (icons.size())));
      float dx = size.x * (float(i) / float(icons.size()+1));
      if(mouseX > pos.x + dx + Abstand * i && mouseX <= pos.x + size.x * (float(i+1) / float(icons.size()+1)) + Abstand * i && mouseY > pos.y + size.y && mouseY < pos.y + 2 * size.y){
        return i; 
      }
    }
    return -1;
  }
  
}
