class Branch { //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
  PVector startPos;   //Position where this branch starts from
  PVector endPos;     //Position where this branch finishes not really needed atm
  PVector widthBranch;    //startWidth, endWidth
  PVector[] positions = new PVector[2 * branchParts];
  PVector[] positionsMiddle = new PVector[branchParts];

  float angleBranchXY;
  float angleBranchZ;       //Not yet implemented
  float endangleBranchXY;
  float endangleBranchZ;    //Not yet implemented
  float parentAngleXY = 0;
  float parentAngleZ = 0;   //Not yet implemented
  float[] prevAngleXY = new float[branchParts];     //every branch part has an angle to follow, here they are stored, to be able to draw it later on
  float[] prevAngleZ = new float[1];                //Not yet implemented
  float[] widthLength = new float[branchParts];     //Saves the width of each branch segment
  float[] branchperc = new float[maxChildsPerTrunk];  //The percentages fromt he branch where new branches will spawn
  float[] widthPerc = new float[maxChildsPerTrunk];   //saves the width at the specified percentages
  float[] widthPercdW = new float[maxChildsPerTrunk]; //No idea anymore, but it does what it should?

  int lengthBranch;
  int treeID;
  int branchID = 0;
  int childs = 1;
  int gen = 0;
  int maxParts = 0;
  int childsPerc = 0;

  boolean isTrunk = false;      //The trunk (beginning of the tree) has different needs

  //-------------------------------------------------------------------------------------------------------
  Branch(int id, int x0, int y0, int z0, int lParent, int wParent, float angleParentXY, float angleParentZ, int branchID, int gen) {
    PVector p0 = new PVector(x0, y0);
    initBranchFromParent(id, p0, lParent, wParent, angleParentXY, angleParentZ, branchID, gen);
  }

  Branch(int id, PVector p0, int lParent, int wParent, float angleParentXY, float angleParentZ, int branchID, int gen) {
    initBranchFromParent(id, p0, lParent, wParent, angleParentXY, angleParentZ, branchID, gen);
  }

  Branch(int id, PVector p0, int maxLength, int branchID) {
    this.branchID = branchID;
    initBranchStart(id, p0, maxLength);
  }

  //-------------------------------------------------------------------------------------------------------
  void initBranchFromParent(int id, PVector p0, int lParent, int wParent, float angleParentXY, float angleParentZ, int branchID, int gen) {
    /**************************************************
     *If the pc overflows, then make this value smaller
     *Cuts off branch production when this id is reached
     **************************************************/
    if (branchID > 700000) {
      forest.trees[0].twigs.remove(forest.trees[0].twigs.size() -1);
      return;
    }

    /**************************************************
     *If the pc overflows, then make this value bigger
     *Checks if RAM is free, if not it stops calculations
     **************************************************/
    long freeMemory = runtime.freeMemory();
    if ((freeMemory / 1024 / 1024) < 12) {
      println("heaplimit reached    "  + (freeMemory / 1024 / 1024));
      forest.trees[0].twigs.remove(forest.trees[0].twigs.size() -1 );
      return;
    }

    /**************************************************
     *Finds out where to spawn new childs in the future
     **************************************************/
    childsPerc = round(twigRandom.sRandom(minChildsPerTrunk, maxChildsPerTrunk));
    for (int i = 0; i < childsPerc; i++) {
      branchperc[i] = twigRandom.sRandom(trunkNoChildHeight, 1);
    }
    branchperc = sort(branchperc);

    this.gen = gen;
    treeID = id;
    this.branchID = branchID;
    startPos = p0;
    lengthBranch = lParent;

    /**************************************************
     *Sets the start angle of this branch
     *Makes sure it stays between 0 and 2*PI
     **************************************************/
    angleBranchXY = (angleRandom.sRandom(angleParentXY - angleChange, angleParentXY + angleChange));
    angleBranchZ = (angleRandom.sRandom(angleParentZ - angleChange, angleParentZ + angleChange));

    while (angleBranchXY < 0)
      angleBranchXY = 2 * PI + angleBranchXY;
    while (angleBranchZ < 0)
      angleBranchZ = 2 * PI + angleBranchZ;

    angleBranchXY = angleBranchXY % (2*PI);
    angleBranchZ = angleBranchZ % (2*PI);

    widthBranch = new PVector(twigRandom.sRandom(startTwigWidth, endTwigWidth) * wParent, 0);
    parentAngleXY = angleParentXY;
    parentAngleZ = angleParentZ;
    calcTwigPath();
  }

  void initBranchStart(int id, PVector p0, int maxLength) {
    isTrunk = true;
    childsPerc = round(twigRandom.sRandom(minChildsPerTrunk, maxChildsPerTrunk));
    for (int i = 0; i < childsPerc; i++) {
      branchperc[i] = twigRandom.sRandom(trunkNoChildHeight, 1);
    }
    branchperc = sort(branchperc);
    treeID = id;
    startPos = p0;
    lengthBranch = round(trunkRandom.sRandom(0.75 * maxLength, maxLength));
    angleBranchXY = 0;
    angleBranchZ = 0;
    float wStart = trunkWidth;
    widthBranch = new PVector(wStart, trunkEndWidth);
    calcTwigPath();
  }

  /**************************************************
   *Adds new children from this branch and looks if
   *the min width and length are adhered
   **************************************************/
  void checkNewBranch(PVector[] ePos, int lO, float dW, float[] AngleChildXY, float AngleChildZ) {
    if (gen >= maxGen)
      return;
    for (int k = 0; k < childsPerc; k++) {
      if (branchperc[k] == 0)
        continue;
      int count = 1;

      while ( widthPerc[k] < minWidthTrunk && count < 10) {
        branchperc[k] = trunkRandom.sRandom(trunkNoChildHeight, 1.0);
        widthPerc[k] = widthLength[round((branchParts - 1) * branchperc[k])];

        count ++;
      }
      int i = round(branchperc[k] *  (maxParts )) ;
      int l =round(  lengthBranch * ((maxParts - float(i))/float(maxParts)));//round(lO * (branchParts - i));
      float endWidth = widthPerc[k] - widthPercdW[k] * (i - 1);
      forest.trees[treeID].twigs.add(0, new Branch(treeID, ePos[i], l, int(endWidth), AngleChildXY[i], AngleChildZ, forest.trees[0].twigs.size(), gen + 1));
    }
  }


  //-------------------------------------------------------------------------------------------------------
  /**************************************************
   *Draws the branch on tG PImage
   *Can be of a colour, with or without stroke
   *Or it can have a texture
   *Makes different parts, interpolates the points
   *to be smooth and adds them to a PShape
   **************************************************/
  void drawBranch() {
    if (positions.length <=0 || maxParts <= 0)
      return;
    PVector[] shapePos = new PVector[2 * maxParts];

    tG.pushMatrix();
    tG.translate(startPos.x, startPos.y);

    PShape twigShape = fillTwig();        //Sets colout
    int pieces = 1;

    /**************************************************
     *calculates lsides[2] for uv coordinates for textures
     *calculates shapePos, coordinates of the border from
     *the branch parts
     **************************************************/
    PVector lSides = new PVector(0, 0);
    float[] dlLeft = new float[maxParts];
    float[] dlRight = new float[maxParts];

    for (int i = 0; i < maxParts; i++) {
      if (i + branchParts - 1 > positions.length)
        continue;
      if ( 2 * maxParts - i > shapePos.length)
        continue;
      shapePos[i] = new PVector(positions[i].x, positions[i].y);
      shapePos[2 * maxParts - i - 1] = new PVector(positions[i + branchParts ].x, positions[i + branchParts ].y);

      if (i > 0) {
        float dx = abs(positions[i].x - positions[i-1].x);
        float dy = -positions[i].y + positions[i-1].y;
        float dyR = -positions[i + maxParts].y + positions[i-1 + maxParts].y;
        dlLeft[i] = sqrt(dx*dx+dy*dy);
        lSides.y += dlLeft[i];

        dlRight[i] = sqrt(dx*dx+dyR*dyR);
        lSides.x += dlRight[i];
      }
    }

    float dx = abs(positions[maxParts-1].x - positions[maxParts-2].x);
    float dy = (-positions[maxParts-1].y + positions[maxParts-2].y) ;
    lSides.y += sqrt(dx*dx+dy*dy);

    float textureScale = 1;
    if (trunks.usedIcon >= 0) {

      pieces = max( floor(lSides.y / trunkimg.height), 1);
      textureScale = max(min(1 - (widthLength[0] / trunkimg.width), 1), 0);
    }

    /**************************************************
     *Draws the final texture with the specific coordinates
     *Still buggy, will take a long time to see why
     **************************************************/
    textureScale = map(textureScale, 0, 1, 0, 0.5);
    for (int i = 0; i < shapePos.length - 1; i++) {
      PVector uv = getUV(i, shapePos.length, textureScale, pieces);
      drawCatmullRom(i, shapePos, uv, twigShape);
    }
    twigShape.endShape();
    tG.shape(twigShape);
    tG.popMatrix();
  }

  /**************************************************
   *Gets UV coordinates for the texture
   **************************************************/
  PVector getUV(int i, int shapePosL, float textureScale, int pieces) {
    float u = 0;
    float v = 0;
    if (i <  0.5*shapePosL ) {
      //u = 1 - (widthLength[i] / widthLength[0]);
      u = map((widthLength[i] / widthLength[0]), 1, 0, textureScale, 0.5);
      v = pieces * (i / (0.5*shapePosL));
    } else {
      u = map((widthLength[ shapePosL - i ] / widthLength[0]), 1, 0, 1 - textureScale, 0.5);
      v = pieces * ((shapePosL - i - 1) / (0.5*shapePosL));
    }
    return new PVector(u, v);
  }

  /**************************************************
   *Calculates the path for a branch
   *and saves the parameters
   **************************************************/
  void calcTwigPath() {
    //Needs revisit if needed at all
    if (millis() > timeStartCalc + 1000 * maxTimeToCalc)
      return;
    nrBranches++;

    float endAngleXY = angleToGo + angleBranchXY;
    float endAngleZ = angleToGo + angleBranchZ;
    float l = lengthBranch / branchParts;
    float dW = (widthBranch.x - widthBranch.y) / (branchParts  -2);
    float dAXY = (angleBranchXY - endAngleXY) / branchParts;
    float dAZ = (angleBranchZ - endAngleZ) / branchParts;

    PVector prevKoord = new PVector(0, 0, 0);
    PVector[] endPoss = new PVector[branchParts];

    Boolean stop = false;

    /**************************************************
     *Makes sure angle stays within 0 and 2*PI
     **************************************************/
    while ( dAXY < 0)
      dAXY = 2 * PI + dAXY;
    while ( dAZ < 0)
      dAZ = 2 * PI + dAZ;
    dAXY = dAXY % (2 * PI);
    dAZ = dAZ % (2 * PI);

    positions[0] = new PVector( - 0.5 * cos(angleBranchXY) *  widthBranch.x, - 0.5 * sin(angleBranchXY) * widthBranch.x, - 0.5 * cos(angleBranchZ) * widthBranch.x);
    positions[branchParts] = new PVector( + 0.5 * cos(angleBranchXY) *  widthBranch.x, + 0.5 * sin(angleBranchXY) * widthBranch.x, + 0.5 * cos(angleBranchZ) * widthBranch.x);
    prevAngleXY[0] = angleBranchXY;
    prevAngleZ[0]  = angleBranchZ;

    for (int jj = 0; jj < widthPerc.length; jj++) {
      widthPerc[jj] = 0;
      widthPercdW[jj] = 0;
    }

    endPoss[0] = new PVector(startPos.x, startPos.y, startPos.z);
    positionsMiddle[0] = new PVector(0, 0, 0);
    widthLength[0] = widthBranch.x;

    int newBranchNr = 0;
    while (branchperc.length > newBranchNr && branchperc[newBranchNr] == 0)
      newBranchNr ++;

    /**************************************************
     *calculates the coordinates and width of
     *each branch part
     **************************************************/
    for (int i = 1; i < branchParts; i++) {
      if (stop == true)
        continue;

      float mW = (widthBranch.x - dW * (i - 1));
      widthLength[i] = mW;
      float rW = twigRandom.sRandom(0.05 * mW);

      float wFact = 1 -  mW / trunkWidth;
      float newAngleChangeXY =  wFact * angleRandom.sRandom(-angleChangePerIteration, angleChangePerIteration);

      // If a new branch spawns here, then the width of the branch gets smaller and changes its direction a bit
      // Could be a lot better, have to revisit sometime
      if (newBranchNr < branchperc.length && round(branchperc[newBranchNr] * branchParts) == i) {

        widthBranch.x *= trunkRandom.sRandom(0.85, 1);
        widthBranch.y *= min(trunkRandom.sRandom(0.85, 1), widthBranch.x * 0.9);
        dW = (widthBranch.x - widthBranch.y) / (branchParts  -2);
        mW = (widthBranch.x - dW * (i - 1));
        widthLength[i] = mW;
        rW = twigRandom.sRandom(0.05 * mW);
        wFact = 1 -  mW / trunkWidth;
        newAngleChangeXY =  wFact * angleRandom.sRandom(-angleChangePerIteration - 0.2 * PI, angleChangePerIteration + 0.2 * PI);

        widthPerc[newBranchNr] = widthBranch.x;
        widthPercdW[newBranchNr] = dW;

        newBranchNr++;
      }

      prevAngleXY[i] = calcPrevAngle(prevAngleXY, i, dAXY, newAngleChangeXY, wFact);

      float z = 0;
      float z1 = 0;
      float z2 = 0;

      float widthDist = (mW + rW) * ( 0.003 + 1);

      float x = prevKoord.x + sin(prevAngleXY[i]) /* * cos(prevAngleZ[i]) */ * l;
      float x1 = x - 0.5 * cos(prevAngleXY[i]) * widthDist ;
      float x2 = x + 0.5 * cos(prevAngleXY[i]) * widthDist  ;

      float y = prevKoord.y - /*cos (prevAngleZ[i]) **/ cos(prevAngleXY[i]) * l;
      float y1 = y - 0.5 * sin(prevAngleXY[i]) * widthDist ;
      float y2 = y + 0.5 * sin(prevAngleXY[i]) * widthDist ;

      //check if maxdist has been reached
      if (forest.trees[0].twigs.size() > 0) {
        PVector posRoot = forest.trees[0].twigs.get(0).startPos;
        PVector posHeight = forest.trees[0].twigs.get(0).endPos;
        float dRoot = dist(posRoot.x, posRoot.y, x+startPos.x, y+startPos.y);
        float dHeight = dist(posHeight.x, posHeight.y, x+startPos.x, y+startPos.y);

        if (dRoot > maxDistFromCore || dHeight > maxDistFromCore) {
          stop = true;
        }
      }
      maxParts++;

      prevKoord = new PVector(x, y, z);
      positions[i] = new PVector(x1, y1, z1);
      positions[i + branchParts] = new PVector(x2, y2, z2);
      positionsMiddle[i] = new PVector(x, y, z);

      endPoss[i] = new PVector(x + startPos.x, startPos.y +y, startPos.z + z) ;
      endPos = new PVector(endPoss[i].x, endPoss[i].y, endPoss[i].z);
    }

    //Should cut off the branch if it gets too long, but didn't implement it correctly
    checkBorder(endPos);

    //check child branches
    println("Branch calc  " + branchID);
    checkNewBranch(endPoss, round(l), dW, prevAngleXY, 0);      //Adds new Branches
    checkNewLeafs(endPoss, round(l), dW, prevAngleXY, prevAngleZ);  //Adds new Leafs
    endangleBranchXY = prevAngleXY[branchParts - 1];
    endangleBranchZ = 0;

    freeMemory();     //frees Meory where it can, because I implemented this function terribly.
  }

  /**************************************************
  *Calculates the new Angle for the new branchpart
  **************************************************/
  float calcPrevAngle(float[] prevAngleXY, int i, float dAXY, float newAngleChangeXY, float wFact) {
    float newVal = prevAngleXY[i-1];// - oldAngleChange;
    newVal += (dAXY + newAngleChangeXY);
    newVal = newVal % (2*PI);
    if (newVal < 0)
      newVal += 2*PI;
    newVal = newVal % ( 2 * PI );
    //add gravity
    while ( newVal < 0)
      newVal = 2 * PI + newVal;
    newVal = newVal % ( 2 * PI);

    if (newVal >0.1 && newVal < PI - 0.1) {
      newVal = newVal + 0.002 * gravity * wFact;
      if (gravity > 0) {
        newVal = min( PI, newVal);
      } else {
        newVal = max(0, newVal);
      }
    } else if (newVal <-0.1 && newVal > -PI + 0.1 || newVal >0.1 + PI && newVal < 2 * PI - 0.1) {
      newVal = newVal - 0.002 * gravity * wFact;
      if (gravity > 0) {
        newVal = max( PI, newVal);
      } else {
        newVal = min(2 * PI, newVal);
      }
    }
    return newVal;
  }

  /**************************************************
  *Frees memory from all variables 
  *that arent needed anymore
  **************************************************/
  void freeMemory() {
    prevAngleXY = new float[0];
    prevAngleZ = new float[0];
    positionsMiddle = new PVector[0];
    branchperc = new float[0];
    widthPerc = new float[0];
    widthPercdW = new float[0];
  }

  void checkBorder(PVector p) {
    if (p.x < forest.minPos.x)
      forest.minPos.x = p.x - leafSize;
    else if (p.x > forest.maxPos.x)
      forest.maxPos.x = p.x + leafSize;
    if (p.y < forest.minPos.y)
      forest.minPos.y = p.y - leafSize;
    else if (p.y > forest.maxPos.y)
      forest.maxPos.y = p.y + leafSize;
  }

  /**************************************************
  *Adds leafs if it can
  **************************************************/
  void checkNewLeafs(PVector[] ePos, int lO, float dW, float[] AngleChildXY, float[] AngleChildZ) {
    int count = 0;
    for ( int z = 0; z < leafDichte * 300; z++) {
      count += leafRandom.sRandom(maxParts);
      int i = count % maxParts;
      float endWidth = widthBranch.x - dW * (i - 1);
      if (endWidth >= leafThickness)
        continue;
      PVector randomPos = drawCatmullRomLeafs(i, ePos);
      randomPos.x += random(-7, 7);
      randomPos.y += random(-7, 7);
      forest.trees[0].leafs.add(new Leaf(randomPos, endWidth));
    }
  }

  /**************************************************
  *Adds Leafs along the interpolated points from
  *the branch parts
  **************************************************/
  PVector drawCatmullRomLeafs(int i, PVector[] points) {
    PVector p0 = (i > 0) ? points[i - 1] : points[i];   // Previous point
    PVector p1 = points[i];                            // Current point
    PVector p2 = points[i + 1];                        // Next point
    PVector p3 = (i < points.length - 2) ? points[i + 2] : points[i + 1]; // Next next point

    float t = random(1);
    PVector p = catmullRom(p0, p1, p2, p3, t);
    return p;
  }

  /**************************************************
  *Connects the points, calculated through 
  *the CatMullRom algorithm
  **************************************************/
  void drawCatmullRom(int i, PVector[] points, PVector uv, PShape twigShape) {
    PVector p0 = (i > 0) ? points[i - 1] : points[i];   // Previous point
    PVector p1 = points[i];                            // Current point
    PVector p2 = points[i + 1];                        // Next point
    PVector p3 = (i < points.length - 2) ? points[i + 2] : points[i + 1]; // Next next point

    for (float t = 0; t <= 1; t += 0.03) {
      PVector p = catmullRom(p0, p1, p2, p3, t);
      //vertex(p.x, p.y);

      twigShape.vertex(p.x, p.y, uv.x, uv.y);
    }
  }

  /**************************************************
  *Catmull-Rom interpolation function
  **************************************************/
  PVector catmullRom(PVector p0, PVector p1, PVector p2, PVector p3, float t) {
    float t2 = t * t;
    float t3 = t2 * t;

    float x = 0.5f * (2 * p1.x +
      (-p0.x + p2.x) * t +
      (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * t2 +
      (-p0.x + 3 * p1.x - 3 * p2.x + p3.x) * t3);

    float y = 0.5f * (2 * p1.y +
      (-p0.y + p2.y) * t +
      (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * t2 +
      (-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * t3);

    return new PVector(x, y);
  }

  /**************************************************
  *Fills the branches with a random brownish colour
  *Or fills them with the selected texture
  **************************************************/
  PShape fillTwig() {
    PShape twigShape;
    twigShape = createShape();
    tG.textureWrap(REPEAT);
    twigShape.beginShape();
    if (trunks.usedIcon >= 0) {
      twigShape.textureMode(NORMAL);
      twigShape.texture(trunkimg);
    } else
      twigShape.fill(getRandomTwigColor(0.9));
    twigShape.strokeWeight(strokeWeight);
    twigShape.stroke(0);
    return twigShape;
  }
}
