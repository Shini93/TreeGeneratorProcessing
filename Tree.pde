
/**************************************************
*This class has all branches in it and all leafs.
*It handled the drawing of the branches, so that
*they appear frame after frame
*The calculations though are all done in the branches
**************************************************/
class Tree {
  int id;
  int maxGreen = 255;
  int maxTrunkSize = 10;      //minimal Size of trunk before it needs to become a leaf
  int MaxTreeSize = 350;      //maximal size of the first trunk
  int BranchParts = 100;

  float backgroundOpa = 1.0;
  float flowers = 0.0;

  ArrayList <Branch> twigs = new ArrayList <Branch>();
  ArrayList <Leaf> leafs = new ArrayList <Leaf>();

  Tree(float backgroundDistance, float springFactor, int id_) {
    id = id_;
    backgroundOpa = backgroundDistance;
    maxGreen = round(springFactor);
    flowers = springFactor*flowers;
  }

  /***************************
  *Draws the whole tree
  *Branches and leafs
  ***************************/
  void drawTree() {
    tG.stroke(0);
    
    for (int z =  actualBranchs; z >= max(0, actualBranchs - branchIt); z--) {
      twigs.get(z).drawBranch();
      //twigs.remove(twigs.size() - 1); //sadly crashed the program from time to time
    }
    println("drawing " + actualBranchs);
    actualBranchs =  max(0, actualBranchs - branchIt);
    
    if (actualBranchs > 0) {
      neededTime = 0.001 * (millis() - timeSinceLastDraw) * float(actualBranchs / branchIt);
      timeSinceLastDraw = millis();
      return;
    }

    tG.noStroke();
    if (usedLeaf >= 0) {
      loadImages();
      leafImgs[usedLeaf].resize(leafSize, leafSize);
    }

    for (int z = 0; z < leafs.size(); z++) {
      leafs.get(z).drawLeaf();
    }
    println((millis() - timeStartCalc)+"  finished drawing Leafs");
    isDrawing = false;
    wasDrawn = true;
    
    if( isStartup  == true){
      fillSlider();
      isStartup = false;
    }
    
  }

  void calcTree(float scaleFactor) {
    thread("start");
    PVector startPos = new PVector(0, 0, 0);
    twigs.add( new Branch( id, startPos, round(sH.getRangedOutput(0)), 0) );
  }
}
