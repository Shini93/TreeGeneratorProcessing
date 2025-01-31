/**************************************
*Calculates new Angle between 0 and 2PI
***************************************/
float newAngle(float AngleNew, float maxAngle) {
  float Angle = AngleNew+miscRandom.sRandom(-maxAngle, maxAngle);
  while (Angle < 0)
    Angle = Angle+2*PI;
  while (Angle > 2*PI)
    Angle = Angle-2*PI;
  return Angle;
}
