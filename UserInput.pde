/**************************************************
*Processing function, executes as soon as the mouse
*is clicked
**************************************************/
void mouseClicked() {
  if (showSliders == false)
    return;
  checkIconFeedback();
}

void checkIconFeedback() {
  int t = trunks.checkFeedback();
  if (t == trunks.usedIcon)
    trunks.usedIcon = -1;
  else if (t != -1) {
    trunks.usedIcon = t;
    trunkimg = trunks.icons.get(t);
  }
  int l = leafs.checkFeedback();
  if (l == leafs.usedIcon) {
    leafs.usedIcon = -1;
    usedLeaf = -1;
  } else if (l != -1) {
    leafs.usedIcon = l;
    usedLeaf = l;
  }
}

/**************************************************
*Needed only for android mode
**************************************************/
void touchEnded() {
  checkIconFeedback();
}

/**************************************************
*Processing function, opens when mouse is clicked
*and moved
**************************************************/
void mouseDragged() {
  if (sH.isOver == true)
    return;
  if (lockedGlobal == true)
    return;
  posScreen.x += (pmouseX - mouseX) * (float(tG.width)/float(width)) * (-2*scaleFact + 1);
  posScreen.y += (pmouseY - mouseY) * (float(tG.height)/float(height)) * (-2*scaleFact + 1);
  wasResized = true;
}

/**************************************************
*Processing function that executes when the mousewheel
*is used
**************************************************/
void mouseWheel(MouseEvent event) {
  scaleFact += 0.1*event.getCount();
  wasResized = true;
}

void updateButtons() {
  if (reset.isFired() == true) {
    setReset();
  } else if (showSlider.isFired()) {
    showSliders = !showSliders;
  } else if (changeSeed.isFired()) {
    seed = round(random(50*millis()));
    seedUsed = true;
    setReset();
  } else if (save.isFired() == true) {
    String name = "y"+year()+"_m"+month()+"_d"+day()+"_h"+hour()+"_m"+minute()+"_s"+second()+ "_" + str(seed) + ".png";
    //name = sketchPath(name);
    if (isAndroid == true)
      saveCanvasToExternalStorage(name);
    else
      tG.save("../../treePics/"+name);
    saved();
  } else if (randomSlider.isFired() == true) {
    randomSlider();
    //leafChanges = !leafChanges;
    //if (leafChanges == true)
    //  leafChange.text = "add Leafs";
    //else
    //  leafChange.text = "remove Leafs";
  } else if (writeSeed.isFired() == true) {
    bWriteSeed = !bWriteSeed;
    if (bWriteSeed == true)
      writeSeed.text = "";
    else {
      seed = int(writeSeed.text);
      seedUsed = true;
      setReset();
    }
  } else if(bAutomode.isFired() == true){
    autoMode = !autoMode; 
  }
  reset.DrawButton();
  save.DrawButton();
  changeSeed.DrawButton();
  randomSlider.DrawButton();
  showSlider.DrawButton();
  writeSeed.DrawButton();
  bAutomode.DrawButton();
}

void setReset() {
  if (isReset == false) {
    isReset = true;
    String t = "Calculating...";
    float w = textWidth(t);
    fill(125);

    rect(0.5*displayWidth-0.5*w, 0.5*displayHeight-1.5*g.textSize, w+2, 2*g.textSize);
    fill(255);
    text(t, 0.5*displayWidth-0.5*w, 0.5*displayHeight);
  } else {
    isReset = false;
    setupProgram();
    seedUsed = false;
    setJSON("last"); 
  }
}

/**************************************************
*Only executed when keys are pressed
*Switches between auto mode and normal mode
**************************************************/
void keyPressed() {
  if (key == 'd' || key == 'D') {
    if (autoMode == true) {
      canSave = false;
      setReset();
      autoPics();
    }
  }
  if (bWriteSeed == true) {
    if (int(key) >= int('0') && int(key) <= int('9')) {
      writeSeed.text += str(key);
    }
  }
}
