//import android.Manifest; //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
//import android.content.pm.PackageManager;
//import android.os.Build;
//import android.os.Environment;
////import android.content.Context;
//import java.io.File;
//import java.io.FileOutputStream;
//import com.hamoid.*;
//VideoExport videoExport;

//TODO::::::
//- Slider für jede generation anlegen.
//- Sollte für geilere Bäume sorgen


import processing.svg.*;

boolean isAndroid = false;
boolean autoMode = false;
boolean isStartup = true;
boolean leafChanges = false;
boolean canSave = false;
boolean wasDrawn = false;
boolean finished = false;
boolean isReset = false;
boolean showSliders = false;
boolean isDrawing = false;
boolean bWriteSeed = false;
boolean wasResized = false;
boolean threadStart =false;
boolean seedUsed = false;
boolean[] sliderUsed;

int minLengthTrunk = 20;
int minWidthTrunk = 5;
int maxChildsPerTrunk = 10;
int minChildsPerTrunk = 2;
int branchParts = 10;
int TrunkPerFrame = 50;   //These are the Trunks drawn per frame (Can watch while drawn)
int nrBranches = 0;
int trunkHeight = 1000;
int trunkWidth = 30;
int trunkEndWidth = 0;
int leafThickness = 5;
int seed = 9;
int leafSize = 10;
int maxDistFromCore = 1000;
int usedLeaf = -1;
int maxGen = 1;
int actualBranchs = 0;
int branchIt = 70;
int test = 1;

float angleChangePerIteration = 0;
float angleToGo = 0;
float chanceNewTwig = 0.01;
float scaleFractor = 4;

float minLengthMul = 0.5;
float maxLengthMul = 0.8;
float angleChange = PI/4;
float endTwigWidth = 0;
float startTwigWidth = 0.5;
float leafDichte = 0.5;
float trunkNoChildHeight = 0.5;
float gravity = 10;
float showSaved = 0;
float leafTransparency = 1;
float sunIntensity, sunSpot = 0;
float strokeWeight = 0;
float timeStartCalc = 0;
float maxTimeToCalc = 40000; //in Seconds
float touchDist = 0;
float scaleFact = 1;

PVector sunPos;
PVector tGSize;
PVector posScreen;

double timeSinceLastDraw = 0;
double neededTime = 0;
float timeSinceStart = 0;

ArrayList <String> help = new ArrayList <String>();

Runtime runtime;

Button reset, save, changeSeed, randomSlider, showSlider, writeSeed, bAutomode;

PGraphics tG, lG, cG, oG;    //Trunk image, leaf image, combined Image, overlay image

PImage leafimg, pedalimg, trunkimg, dummyLight;
PImage dummy;
PImage[] leafImgs;

Byte state = 2;
Byte Calculating = 0;
Byte finishedDrawing = 1;
Byte finishedAll = 2;

Forest forest;
SliderHandler sH;
SelectIcon trunks;
SelectIcon leafs;

selfRandom srandom;
selfRandom trunkRandom;
selfRandom twigRandom;
selfRandom angleRandom;
selfRandom miscRandom;
selfRandom leafRandom;

//Context context;


void setup() {
  fullScreen(P2D, 2);
  if (autoMode == true)
    seed = round(random(99999999));
  //videoExport = new VideoExport(this, "pgraphics.mp4");
  //videoExport.startMovie();
  
  runtime = Runtime.getRuntime();
  
  PFont myFont = createFont("Laksaman Bold", sizeFont, true);
  textFont(myFont);
  tGSize = new PVector(2*width, 2*height);
  sunPos = new PVector(0, 0);
  posScreen = new PVector(0, 0);

  trunks = new SelectIcon("trunklook", new PVector(0.01*width, 0.72*height), new PVector(0.3*width, 0.1*height));
  trunks.addIcon("Test");
  trunks.addIcon("Ahorn");
  trunks.addIcon("Birch");
  trunks.addIcon("Light");
  trunks.addIcon("Normal");
  trunks.addIcon("Mossy");

  leafs = new SelectIcon("leafs", new PVector(0.01*width + 0.32 * width, 0.72*height), new PVector(0.2*width, 0.1*height));
  leafs.addIcon("ahorn_summer");
  leafs.addIcon("Leaf_summer");
  leafs.addIcon("pedals");
  loadImages();

  //Needed only if it should run on android
  // context = getContext();
  //requestPermission("android.permission.WRITE_EXTERNAL_STORAGE", "initWrite");
  //requestPermission("android.permission.READ_EXTERNAL_STORAGE", "initRead");
  //requestPermission("android.permission.MANAGE_EXTERNAL_STORAGE", "initManage");

  sH = new SliderHandler();
  int h = round(0.8*floor(float(displayHeight) / float(28)));
  sH.sHeight = floor(h * 0.75);
  sH.sAbstand = h;
  textSize(sH.sHeight);
  if (isAndroid == true) {
    sH.sWidth = round(0.5*displayWidth);
  } else {
    sH.sWidth = round(0.25*displayWidth);
  }
  initSlider();
  updateValues();
  setupProgram();
  //autoPics();  //Needed only when the program is set to automatic mode
}

//Might be needed for android
void initWrite(boolean granted) {
}
void initRead(boolean granted) {
}
void initManage(boolean granted) {
}

void saveCanvasToExternalStorage(String fileName) {
  // Check if the WRITE_EXTERNAL_STORAGE permission is granted
  // Permission granted, save the canvas to external storage
  // String fileName = "tree.png";

  String ext = "/storage/9824-09F1";
  String sd = "/sdcard";

  File mediaStorageDir = new File(sd, "WonderfulTrees");

  if (!mediaStorageDir.exists()) {
    if (!mediaStorageDir.mkdirs()) {
    }
  }

  String filePath = sd + "/WonderfulTrees/" + fileName;
  tG.save(filePath);
}

/**************************************************
*This code is executed every frame. All calculations
*And drawings that are done after the initial state
*are started here!
**************************************************/
void draw() {
  if(state == Calculating){
    forest.trees[0].calcBranches();
    if(forest.trees[0].twigs.size() <= 0)
      state = finishedDrawing;
    resizeI();
  }
  if(state == finishedDrawing){
    println("------------------------------");
      dummyLight = createGraphics(tG.width, tG.height, P2D);
      dummyLight = tG.get();
      PVector sun = new PVector(sunPos.x*tG.width, sunPos.y*tG.height);
      setLight(sun, 0.001*sunIntensity*sqrt(tG.width*tG.width+tG.height*tG.height));
      wasDrawn = true;
      resizeI();
      finished = true;
      resetSliderUsed();
      state = finishedAll;
  }
  if (wasResized == true) {
    resizeI();
  }
  ///**************************************************
  //*Only started when calculations are finished 
  //*and branches have to be drawn
  //**************************************************/
  //if (isDrawing == true) {
  //  forest.drawForest(false);
  //  resizeI();
  //}

  ///**************************************************
  //*Starts the drawing process, only executed once 
  //*per drawing session
  //**************************************************/
  //if (wasDrawn == false && isDrawing == false) {
  //  forest.drawForest(true);
  //  resizeI();
  //  println("isDrawing = false");
  //  finished = false;
  //}

  ///**************************************************
  //*Starts this only after the drawing is finished
  //**************************************************/
  //if (wasDrawn == true && isDrawing == false) {
  //  if (finished == true) {
  //    autoPics(); //saves a pc automatically and randomizes sliders if wanted
  //  }

  //  /**************************************************
  //  *draws a light on the tree. 
  //  *Changes and calculates for each pixel
  //  **************************************************/
  //  if (finished == false) {
  //    println("------------------------------");
  //    dummyLight = createGraphics(tG.width, tG.height, P2D);
  //    dummyLight = tG.get();
  //    PVector sun = new PVector(sunPos.x*tG.width, sunPos.y*tG.height);
  //    setLight(sun, 0.001*sunIntensity*sqrt(tG.width*tG.width+tG.height*tG.height));
  //    wasDrawn = true;
  //    resizeI();
  //    finished = true;
  //    resetSliderUsed();
  //  }
  //}
  if (wasResized == true) {
    resizeI();
  }
  background(125);
  image(dummy, 0, 0);

  updateSlider();
  checkHelp();
  if (millis() - showSaved < 2000) {
    fill(255);
    rect(0.5*width - 15, 0.5*height-45, 60, 40);
    fill(0);
    text("saved", 0.5*width - 15, 0.5*height-15);
  }
  loadingBar();

  fill(255);
  text("Seed:  "+seed, width - 30 - textWidth("Seed:  xxxxxxx"), height - 3*g.textSize);
  
  fill(255);
  text("Stack:  " + forest.trees[0].twigs.size(), width - 30 - textWidth("Seed:  xxxxxxx"), height - 2*g.textSize);
  
  text("Time:  " + int(floor(0.001 * (millis() - timeSinceStart) / 60)) + ":" + int(floor(0.001 * (millis() - timeSinceStart))) % 60, width - 30 - textWidth("Seed:  xxxxxxx"), height - g.textSize);

  updateButtons();

  if (isReset == true)
    setReset();

  //if (autoMode == true) {
  //  if (float(forest.trees[0].twigs.size()) / float(branchIt) > 500) {
  //    println("too many calcs, refresh all");
  //    randomSlider();

  //    // randomize trunk and leaflook
  //    trunks.usedIcon = round(random(-1, trunks.icons.size() - 1)) ;
  //    if (trunks.usedIcon != -1)
  //      trunkimg = trunks.icons.get( trunks.usedIcon);
  //    leafs.usedIcon = round(random(-1, leafs.icons.size() - 1)) ;
  //    usedLeaf = leafs.usedIcon;
  //    updateValues();
  //    //calc new
  //    seed = round(random(50*millis()));
  //    seedUsed = true;
  //    setReset();
  //    canSave = true;
  //  }
  //}

  //videoExport.saveFrame();
}

/**************************************************
*Help window with text opens and shows what
*The slider hovered does
**************************************************/
void checkHelp() {
  for (int b = 0; b < sH.buttons.size(); b++) {
    if (sH.buttons.get(b).isActive == true || sH.buttons.get(b).isHovered == true) {
      if (sH.buttons.get(b).fired == false && mousePressed == true && (mouseX < sH.buttons.get(b).x || mouseX > sH.buttons.get(b).x+ sH.buttons.get(b).boxSizeX || mouseY > sH.buttons.get(b).y || mouseY < sH.buttons.get(b).y- sH.buttons.get(b).boxSizeY) ) {
        sH.buttons.get(b).isActive = false;
        return;
      }
      fill(255);
      float textArea = textWidth(help.get(b)) * g.textSize * 2;
      float w = sqrt(textArea / (float(9)/float(16)));
      float h = w * ( float(9)/float(16));
      float x0 = 0.5 * (width - w) ;
      float y0 = 0.5 * (height - h);
      rect(x0, y0, w+textWidth("WWW"), h+g.textSize);
      fill(0);

      float lines = h / g.textSize;
      int wordsWidth = round(w/(textWidth(help.get(b))/(help.get(b).length())));
      for (int i = 0; i < float(help.get(b).length()); i+=wordsWidth) {
        int e = min(i+wordsWidth, help.get(b).length());
        String s = help.get(b).substring(i, e);
        int tWidth = round(textWidth(s));
        text(s, x0+0.5*(w-tWidth+textWidth("WWW")), y0 + (i/wordsWidth +0.5) * g.textSize * 2);
      }
    }
  }
}

void initRandoms() {
  srandom = new selfRandom(seed);
  trunkRandom = new selfRandom(round(srandom.sRandom(seed)));
  twigRandom = new selfRandom(round(srandom.sRandom(2*seed)));
  angleRandom = new selfRandom(round(srandom.sRandom(3*seed)));
  miscRandom = new selfRandom(round(srandom.sRandom(4*seed)));
  leafRandom = new selfRandom(round(srandom.sRandom(5*seed)));
}

void setupProgram() {
  isDrawing = false;
  initButtons();
  actualBranchs = 0;
  timeStartCalc = millis();
  initRandoms();
  println("seed = "+srandom.getSeed());
  writeSeed.text = str(srandom.getSeed());
  // loadImages();
  initGraphics();

  if (checkSliderUsed() == true || seedUsed == true) {
    startForest();
    forest.AddTree();

    forest.trees[0].calcTree(1);
    actualBranchs = forest.trees[0].twigs.size() - 1;
  } else {
    for (int b = 0; b < forest.trees[0].twigs.size(); b++)
      forest.trees[0].twigs.get(b).drawBranch();
  }

  println((millis() - timeStartCalc) +"  finished dcalculating tree");
  wasDrawn = false;
  resizeImg();
}

void loadImages() {
  leafImgs = new PImage[3];
  leafImgs[0] = loadImage("leafs/ahorn_summer.png");
  leafImgs[1] = loadImage("leafs/Leaf_summer.png");
  leafImgs[2] = loadImage("leafs/pedals.png");
  //leafimg = loadImage("leafs/ahorn_summer.png");
  //pedalimg = loadImage("leafs/pedals.png");
  usedLeaf = leafs.usedIcon;
  if (trunks.usedIcon != -1)
    trunkimg = trunks.icons.get(trunks.usedIcon);
}

void initGraphics() {
  initTreeGraphic(new PVector(trunkHeight * 2, trunkHeight));
  initOverlayGraphic();
  tG.beginDraw();
  tG.clear();
  tG.endDraw();
}


void initTreeGraphic(PVector size) {
  if (size == null)
    size = new PVector(100, 100);
  tG = createGraphics(round(size.x), round(trunkHeight),P2D);
  tG.beginDraw();
  tG.clear();
}

void initOverlayGraphic() {
}

void initButtons() {
  reset = new Button(10, height-30, "reset");
  save = new Button(210, height-30, "save");
  changeSeed = new Button(410, height-30, "changeSeed");
  randomSlider = new Button(610, height-30, "randomize Slider");
  showSlider = new Button(width - 150, 30, "slider");
  writeSeed = new Button(width - 30 - int(textWidth("Seed:  ")), height - int(4 * g.textSize), "12345678");
  writeSeed.boxSizeX = int(textWidth("XXXXXXX"));
  writeSeed.boxSizeY = 20;
  bAutomode = new Button(width - int(textWidth("Automode: false")), 100, "automode: " + str(autoMode));
  bAutomode.boxSizeX = int(textWidth("Automode: false"));
}

void startForest() {
  forest = new Forest(1);
}

void saved() {
  showSaved = millis();
}

  /**************************************************
  *Creates a random brownish colour for the branches
  **************************************************/
color getRandomTwigColor(float lightning) {
  int red = round(random(158, 168));
  int green = round(random(58, 75));
  int blue = 0;
  return color(lightning * red, lightning * green, lightning * blue);
}

//Does not work yet, I think
void changeLeafs() {

}

//0-100
float lightMul(float dist, float intensity, float sNormal) {
  float number = -0.005/sNormal;
  float dummy =  number*dist+2;
  return 1 + intensity*dummy;
} 

//changes color of stuff
void setLight(PVector lightPos, float intensity) {
  if (millis() > timeStartCalc + 1000 * maxTimeToCalc)
    return;
  tG.beginDraw();
  dummyLight.loadPixels();
  float sNormal = sunSpot * 0.001* sqrt(tG.width*tG.width+tG.height*tG.height);
  for (int x = 0; x < tG.width; x++) {
    for (int y = 0; y < tG.height; y++) {
      color c = dummyLight.pixels[x+y*tG.width];
      if ( alpha(c) == 0)
        continue;
      float red = red(c);
      float green = green(c);
      float blue = blue(c);

      float disLight = dist(lightPos.x, lightPos.y, x, y);
      float lMul = lightMul(disLight, intensity, sNormal);

      red = min(red*lMul, 255);
      green = min(green*lMul, 255);
      blue = min(blue*lMul, 255);

      c = color(red, green, blue);
      //  println("1  "+dummyLight.pixels[x+y*tG.width]);
      tG.pixels[x+y*tG.width] = c;
      //  println("2  "+dummyLight.pixels[x+y*tG.width]);
    }
  }
  tG.updatePixels();
  tG.endDraw();
  println(intensity+"   "+(millis() - timeStartCalc)+"  finished Lighting");
}

void resizeImg() {
  scaleFact = 0;
  wasResized = true;
}

void resizeI() {
  int x0 = round(scaleFact * tG.width + posScreen.x);
  int y0 = round(scaleFact * tG.height + posScreen.y);
  float sx = float(tG.width)/float(width);
  float sy = float(tG.height)/float(height);
  int w = round(tG.width -sx*scaleFact*tG.width);
  int h = round(tG.height -sy* scaleFact*tG.height);
  dummy = tG.get(x0, y0, w, h);
  if (dummy.width>0)
    dummy.resize(width, height);
  wasResized = false;
}


void loadingBar() {
  PVector pos = new PVector(10, height-70);
  PVector size = new PVector(800, 30);

  //background
  fill(125);
  rect(pos.x, pos.y, size.x, size.y);

  //progressbar
  fill(0, 255, 0);
  float dW = (forest.trees[0].twigs.size()-actualBranchs)/float(forest.trees[0].twigs.size());
  rect(pos.x, pos.y, size.x*(dW), size.y);
}

void autoPics() {
  if (autoMode == false)
    return;
  //saving pic
  String name = "";
  if (canSave == true) {
    name = "y"+year()+"_m"+month()+"_d"+day()+"_h"+hour()+"_m"+minute()+"_s"+second()+".png";
    String path = "";
    //name = sketchPath(name);

    if (tG.height < 800)
      name = "small/"+name;
    else if (tG.height < 1300)
      name = "medium/"+name;
    else if (tG.height < 2000)
      name = "big/"+name;
    else if (tG.height < 4000)
      name = "hughe/"+name;
    else if (tG.height < 7000)
      name = "gigantic/"+name;
    else
      name = "maximal/"+name;


    if (isAndroid == true) {
      path = name;
      saveCanvasToExternalStorage(name);
    } else {
      path = "../../treePics/"+name;
      println("saved to "+path);
      tG.save(path);
    }

    while (fileExists( "G:/programmiertes/processing/Grafik/Wald/treePics/" + name) == false) {
      println(millis());
    }

    saved();
  }
  setJSON(name);
  //randomize sliders
  randomSlider();

  // randomize trunk and leaflook
  trunks.usedIcon = round(random(-1, trunks.icons.size() - 1)) ;
  if (trunks.usedIcon != -1)
    trunkimg = trunks.icons.get( trunks.usedIcon);
  leafs.usedIcon = round(random(-1, leafs.icons.size() - 1)) ;
  usedLeaf = leafs.usedIcon;
  updateValues();
  //calc new
  seed = round(random(50*millis()));
  seedUsed = true;
  setReset();
  canSave = true;
}

void randomSlider() {
  for (int s = 0; s < sH.sliders.size() - 4; s++) {
    float r = random(1);
    if ( s < 1)
      r = random(0.2, 0.7);
    if (s== 1)
      r = random(sH.getPerc(0)*0.5, min(1,sH.getPerc(0)*1.3));
    else if (s == 3)
      r = random(0.05, 0.3);
    else if (s >= 4 && s <= 5)
      r = random(0.04, 0.1);
    else if (s == 6)
      r = random(1, 1);
    else if (s == 7)
      r = random(sH.getPerc(6), 1);
    else if ( s == 8)
      r = random(0.7, 1);
    else if ( s == 9)
      r = 1;
    else if (s == 10)
      r = random(0.4);
    else if ( s == 11)
      r = random(sH.getPerc(10), 0.7);
    else if (s == 12 || s == 14)
      r = random(0.4, 0.6);
    else if ( s == 13)
      r = random(0.6, 1);

    else if (s == 17)
      r = 0.6;
    else if ( s == 16)
      r = 0.8;
    else if ( s == 18)
      r = 0.98;
    sH.setSliderPos(s, r);
  }
}

boolean fileExists(String path) {
  File file=new File(path);
  println(file.getName());
  boolean exists = file.exists();
  if (exists) {
    println("true");
    return true;
  } else {
    println("false");
    return false;
  }
}

void exit(){
  setJSON("last"); 
}

void fillSlider(){
  JSONObject json = getJSON("last"); 
  for(int s = 0; s < sH.sliders.size(); s++){
    sH.setSliderPos(s, json.getFloat(str(s)));
  }
  seed =  json.getInt("Seed");
  println("slider filled");
}
