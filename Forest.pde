/**************************************************
*The idea was at the beginning to spawn multiple trees
*in a forest. Obviously the calculations are too 
*eccessive for multiple trees at once, so the forst 
*only spawns one single tree to calculate and draw
**************************************************/
class Forest {
  int nrTrees = 1;
  int processedTree = 0;

  float spring = 255;
  float[] backgroundDistance;      //how far Trees are in the Background
  PVector minPos = new PVector(0,0);
  PVector maxPos = new PVector(0,0);
  boolean calculating = false;

  Tree[] trees = new Tree[nrTrees];

  Forest() {
    int treeId = 0;
    float springFactor = srandom.sRandom(255);
    float backGroundDistance = 1;

    trees[treeId] = new Tree(backGroundDistance, springFactor, treeId);
  }

  Forest(int Trees) {
    nrTrees = Trees;
    randomBackgroundDistances();
    //AddTree();
  }

  /**************************************************
   *gives each tree a distance to the background (0-1)
   *randomizes them with a given seed
   *sorts them to draw the furthest trees first
   ***************************************************/
  void randomBackgroundDistances() {
    backgroundDistance = new float[nrTrees];
    for (int t=0; t<nrTrees; t++) {
      backgroundDistance[t] = srandom.sRandom(1);
    }
    backgroundDistance = sort(backgroundDistance);
  }

  /***************************************************
   *starts the calculation of a new tree
   *only called once the tree before is finished
   ***************************************************/
  void AddTree() {
    if (processedTree < nrTrees) {
      trees[processedTree] = new Tree(backgroundDistance[processedTree], spring, processedTree);
      processedTree++;
    }
  }
  
  void drawForest(boolean init){
    float w = + maxPos.x - minPos.x;
    float h =   maxPos.y - minPos.y;
    tG.endDraw();
    
    int x = displayWidth;
    int y = displayHeight;
    
    
    if(w/h < float(x)/float(y)){
       w = h * (float(x)/float(y));
    }
    else{
       h = w * (float(y)/float(x));  
    }
    if(w < 200)
      w = 200;
    if(h < 200)
      h = 200;
    if(init == true)  
      initTreeGraphic(new PVector(w,h));
    else
      tG.beginDraw();
    tG.pushMatrix();
    float dW = -(maxPos.x/minPos.x);
    int offset = 0;
    if(minPos.x*1.1 < -0.5*tG.width){
      offset = -round(1.1*minPos.x + 0.5*tG.width);
    }
    else if(1.1*maxPos.x > tG.width){
      offset = round(tG.width - 1.1*maxPos.x);
    }
    
    drawTreeParts(offset);
  }
  
  void drawTreeParts(int offset){
    isDrawing = true;
    tG.translate(0.5*(tG.width) + offset,tG.height-maxPos.y);
    for(int t = 0; t < nrTrees; t++)
      trees[t].drawTree();
    tG.popMatrix();
    tG.endDraw(); 
  }
  
}
