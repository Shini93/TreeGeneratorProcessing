/**************************************************
*a leaf can be drawn on a specific point
*Can be drawn either as an image, or an ellipse
**************************************************/
class Leaf {
  PVector pos;
  float angle;

  Leaf(PVector p, float w) {
    pos = new PVector(p.x, p.y, p.z);
    pos.x = pos.x;// + leafRandom.sRandom(-w,w);
    pos.y = pos.y;// + leafRandom.sRandom(-w,w);
    pos.z = pos.z;// + leafRandom.sRandom(-w,w);
    drawLeaf();
  }

  void drawLeaf() {
    if (usedLeaf == -1) {
      float mul = 0.001 * pos.z + 1;
      float whitness = 1;

      int red = round(random(20) * whitness);
      int green = round(random(140, 180) * whitness);
      int blue = round(random(20) * whitness);
      //if(pos.z < 0)
      //  return;
      tG.strokeWeight(strokeWeight);
      tG.fill(color(red, green, blue), leafTransparency);
      tG.ellipse(pos.x, pos.y, leafSize * mul * random(0.5, 1.3), leafSize * mul * random(0.5, 1.3));
      return;
    }
    tG.pushMatrix();
    tG.translate(pos.x, pos.y);
    tG.rotate(random(2*PI));
    tG.tint(255, leafTransparency);
    tG.image(leafImgs[usedLeaf], -0.5*leafImgs[usedLeaf].width, -leafImgs[usedLeaf].height);
    tG.popMatrix();
  }
}
