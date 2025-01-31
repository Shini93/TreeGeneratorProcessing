/**************************************************
*Updates all slider and icons
**************************************************/
void updateSlider() {
  if (showSliders == false)
    return;
  chanceNewTwig = sH.getRangedOutput(0);
  sliderUsed[sH.drawAndUpdateSlider()] = true;
  updateValues();
  
  trunks.drawIcon();
  leafs.drawIcon();
}

void resetSliderUsed() {
  for (int s = 0; s < sH.sliders.size(); s++)
    sliderUsed[s] = false;
}

boolean checkSliderUsed(){
  for (int s = 0; s < sH.sliders.size(); s++)
    if(sliderUsed[s] == true)
      return true;
  return false;
}

/**************************************************
*Adds new sliders once.
*Sliders can get a Name, a width and height
*an range for the output, a colour and
*an initial value
**************************************************/
void initSlider() {  
  float androidMul = 0.75; //0.6;
  
  sH.addSlider("trunkHeight", 0.0, 10000.0 * androidMul, 0.2, 0);
  sH.addSlider("trunkWidth", 0.0, 1000.0 * androidMul, 0.2, 0);
  sH.addSlider("trunkEndWidth", 0.0, 200.0 * androidMul, 0.0, 0);

  sH.addSlider("trunkNoChildHeight");
  sH.defRange(0, 1);
  sH.setSliderPos(0.2);

  //twig lengths
  sH.addSlider("minPossibleLength");
  sH.defRange(0, 1000);
  sH.setSliderPos(0.1);
  sH.setColor(1);

  sH.addSlider("minPossibleTrunk");
  sH.defRange(0, 100);
  sH.setSliderPos(0.05);
  sH.setColor(1);

  sH.addSlider("minLengthMul");
  sH.defRange(0, 4);
  sH.setSliderPos(0.1);
  sH.setColor(1);

  sH.addSlider("maxLengthMul");
  sH.defRange(0, 4);
  sH.setSliderPos(0.2);
  sH.setColor(1);

  //twig widths
  sH.addSlider("startTwigWidthMin");
  sH.defRange(0, 1);
  sH.setSliderPos(0.6);
  sH.setColor(1);

  sH.addSlider("startTwigWidthMax");
  sH.defRange(0, 1);
  sH.setSliderPos(0.8);
  sH.setColor(1);

  //children
  sH.addSlider("minChildsPerTrunk");
  sH.defRange(1, 20 * androidMul);
  sH.setSliderPos(0.1);
  sH.setColor(1);

  sH.addSlider("maxChilds");
  sH.defRange(1, 20 * androidMul);
  sH.setSliderPos(0.3);
  sH.setColor(1);

  //Angles
  sH.addSlider("angleChange");
  sH.defRange(-180, 180);
  sH.setSliderPos(0.6);
  sH.setColor(2);

  sH.addSlider("angleChangeIteration");
  sH.defRange(-0.3*180, 0.3*180);
  sH.setSliderPos(0.65);
  sH.setColor(2);

  sH.addSlider("gravity");
  sH.defRange(-20, 20);
  sH.setSliderPos(0.4);
  sH.setColor(2);

  //misc
  sH.addSlider("chanceNewTwig");
  sH.defRange(0.01, 1);
  sH.setColor(3);

  sH.addSlider("branchParts");
  sH.defRange(0, 100);
  sH.setSliderPos(0.5 * androidMul);
  sH.setColor(3);

  sH.addSlider("maxGeneration", 1, 10, 0.2, 3);
  sH.addSlider("maxDistFromCore", 100, 12000 * androidMul, 1, 3);

  //leafs
  sH.addSlider("leafDichte");
  sH.defRange(0, 1);
  sH.setSliderPos(0.2);
  sH.setColor(4);

  sH.addSlider("leafThickness");
  sH.defRange(0, 30);
  sH.setSliderPos(0.2);
  sH.setColor(4);

  sH.addSlider("leafSize");
  sH.defRange(1, 50);
  sH.setSliderPos(0.15);
  sH.setColor(4);

  sH.addSlider("leafTransparenz");
  sH.defRange( 0, 255);
  sH.setSliderPos(1);
  sH.setColor(4);

  //Sun parameters
  sH.addSlider("SunPosX");
  sH.defRange(0, 1);
  sH.setColor(5);

  sH.addSlider("SunPosY");
  sH.defRange(0,1.3);
  sH.setColor(5);

  sH.addSlider("Sun Intensity");
  sH.defRange( 0, 1);
  sH.setSliderPos(0);
  sH.setColor(5);

  sH.addSlider("sunSpot");
  sH.defRange(0, 1);
  sH.setColor(5);
  
  //Stroke or no stroke for Leafs AND branches
  sH.addSlider("StrokeWeight");
  sH.defRange(0, 5);
  sH.setColor(0);

  sliderUsed = new boolean[sH.sliders.size()];
  for(int s = 0; s < sH.sliders.size(); s++)
    sliderUsed[s] = true;

  initHelpText();

  if(autoMode == true)
    randomSlider();
}

/**************************************************
*These texts appear when the names of the Sliders
*are hovered, to help understand what the slider does
**************************************************/
void initHelpText(){
  /*0*/ help.add("Sets the maximum length from the roots of the tree to the furthest end of each branch (maximum reachable size from the tree)"); 
  /*1*/ help.add("Sets the starting width of the tree trunk. All branches take over part of the width of their parent branch. So a thicker Trunk makes for thicker branches."); 
  /*2*/ help.add("Sets the width the trunk should have at the very end. A small width is recommended");
  /*3*/ help.add("Sets the height at which a branch can start to spawn new branches. Example: value of 0 has the possibillity to grow new branches from the root. While a value of 0.5 lets branches only start at half of the length of the branch.");
  /*4*/ help.add("The minimal length of branches can be set here. There can be no branch that is smaller than this size. (stops making a lot of small twigs here and there)");
  /*5*/ help.add("The minimal width of branches can be set here. There can be no branch that is thinner than this size. (stops making a lot of thin twigs here and there)");
  /*6*/ help.add("When a branch spawns from its parent, then the new branch gets a set length. This length can vary bewteen a minumum length (which you set here) and a maximum length (which you set in the next slider"); 
  /*7*/ help.add("When a branch spawns from its parent, then the new branch gets a set length. This length can vary bewteen a minumum length (which you set a slider higher) and a maximum length (which you set here)");
  /*8*/ help.add("When a branch spawns from its parent, then the new branch gets a set width. This width can vary bewteen a minumum length (which you set here) and a maximum width (which you set in the next slider");
  /*9*/ help.add("When a branch spawns from its parent, then the new branch gets a set width. This width can vary bewteen a minumum length (which you set a slider higher) and a maximum width (which you set here)");
 /*10*/ help.add("Every branch, which is wide and long enough can spawn new branches. With this slider you can set how many new branches a branch has to spawn.");
 /*11*/ help.add("Every branch, which is wide and long enough can spawn new branches. With this slider you can set how many new branches can spawn.");
 /*12*/ help.add("When a new branch spawns, then its starting angle changes in regards to the parent branch at this point in space. This slider changes the angle in regards to the parent in degree");
 /*13*/ help.add("A branch is not perfectly straight. With this slider the 'wobbliness' of a branch can be altered. (Small changes in the angle to in the branch");
 /*14*/ help.add("Each branch can be pulled towards the earth or towards the sky with the gravity slider. The thinner the branch the stronger the gravity will be.");
 /*15*/ help.add("If you like the actual seed for the randomness, then this slider can still change the look of the tree.");
 /*16*/ help.add("A branch consists of a set number of branchparts. Each branchpart can change the 'wobbliness' of the branch as a whole. The more branchparts there are, the more detailed the tree gets, but the more has to be calculated.");
 /*17*/ help.add("Each time a set of branches is created, it becomes a different generation. With this slider you can cap the simulation at a given generation");
 /*18*/ help.add("Caps tree branches when they are too far away fromt he center.");
 /*19*/ help.add("Sets how many leafs are generated where they are allowed");
 /*20*/ help.add("A branch can spawn leafs if the trunk is thin enough. With this slider you can set the maximum thickness, which can still produce leafs");
 /*21*/ help.add("Sets the size leafs can have.");
 /*22*/ help.add("Sets the transparency of leafs. Lets them blend in together more");
 /*23*/ help.add("A sunspot can be set. It makes the color brighter where it hits, but makes the color darker the further away the spot is. This slider sets the x position of the sunspot");
 /*24*/ help.add("A sunspot can be set. It makes the color brighter where it hits, but makes the color darker the further away the spot is. This slider sets the y position of the sunspot");
 /*25*/ help.add("A sunspot can be set. It makes the color brighter where it hits, but makes the color darker the further away the spot is. This slider sets the intensity of the sunspot (brightness and darkness intensify)");
 /*26*/ help.add("A sunspot can be set. It makes the color brighter where it hits, but makes the color darker the further away the spot is. This slider sets the radius of the sunspot.");
 /*27*/ help.add("Changes the thickness of the lines of the Tree");

}

/**************************************************
*Updates all values, no matter if they were changed
*or not.
**************************************************/
void updateValues() {
  if(sH.sliders.size() <= 0)
    return;
  trunkHeight = round(sH.getRangedOutput("trunkHeight"));
  trunkWidth = round(sH.getRangedOutput("trunkWidth"));
  trunkEndWidth = round(sH.getRangedOutput("trunkEndWidth"));
  trunkNoChildHeight = sH.getRangedOutput("trunkNoChildHeight");

  minLengthTrunk = round(sH.getRangedOutput("minPossibleLength"));
  minWidthTrunk = round(sH.getRangedOutput("minPossibleTrunk"));
  minLengthMul = sH.getRangedOutput("minLengthMul");
  maxLengthMul = sH.getRangedOutput("maxLengthMul");
  startTwigWidth = sH.getRangedOutput("startTwigWidthMin");
  endTwigWidth = sH.getRangedOutput("startTwigWidthMax");
  minChildsPerTrunk = round(sH.getRangedOutput("minChildsPerTrunk"));
  maxChildsPerTrunk = round(sH.getRangedOutput("maxChilds"));
  angleChange = (PI/180)*sH.getRangedOutput("angleChange");
  angleChangePerIteration =  (PI/180)*sH.getRangedOutput("angleChangeIteration");
  gravity = sH.getRangedOutput("gravity");
  chanceNewTwig = sH.getRangedOutput("chanceNewTwig");
  branchParts = round(sH.getRangedOutput("branchParts"));
  maxGen = round(sH.getRangedOutput("maxGeneration"));
  maxDistFromCore = round(sH.getRangedOutput("maxDistFromCore"));
  leafDichte = sH.getRangedOutput("leafDichte");
  leafThickness = round(sH.getRangedOutput("leafThickness"));
  leafSize = round(sH.getRangedOutput("leafSize"));
  leafTransparency = round(sH.getRangedOutput("leafTransparenz"));
  sunPos.x = sH.getRangedOutput("SunPosX");
  sunPos.y = sH.getRangedOutput("SunPosY");
  sunIntensity = sH.getRangedOutput("Sun Intensity");
  sunSpot = sH.getRangedOutput("sunSpot");
  strokeWeight = sH.getRangedOutput("StrokeWeight");
}
