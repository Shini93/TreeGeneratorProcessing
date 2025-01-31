/**************************************************
*This class creates random numbers from a seed.
*It always creates the same random numbers
*in succession each time the program
*is started with the same seed 
**************************************************/
class selfRandom {
  int noiseSeed = -1;
  int countMul = 0;                    //0 to 2; for more of a not normal distribution
  float randomCount = -3400000;      //how man times selfRandom is called in this class
  float closeDist = 100;
  float closeCount = 0;

  selfRandom() {
    noiseSeed = round(random(32000));
    noiseSeed(noiseSeed);
  }
  selfRandom(int seed) {
    noiseSeed = seed;
    noiseSeed(seed);
  }

  int getSeed() {
    return noiseSeed;
  }

  /**************************************************
  *Calculates a "random" numer between 0 and 1
  **************************************************/
  float calcRandom(float val) {
    float pow = 1;
    if ( countMul == 0)
      pow = 0.5;
    else if ( countMul == 2)
      pow = 2;
    countMul ++;
    if ( countMul > 2)
      countMul = 0;
    float result = pow(noise(val), pow)*1.5-0.2;
    if ( result > 1)
      result = 1;
    else if ( result < 0)
      result = 0;
    return result;
  }

  float sRandom() {
    randomCount+= 100;
    return calcRandom(randomCount);
  }
  float sRandom(float max) {
    return max* sRandom() ;
  }
  float sRandom(float min, float max) {
    return min + (max - min) * sRandom();
  }

  float sRandom(int min, int max) {
    return min + (max - min) * sRandom();
  }

  float sRandom(float min, int max) {
    return min + (max - min) * sRandom();
  }

  float closeRandom() {
    closeCount += closeDist;
    return calcRandom(closeCount);
  }

  float closeRandom(float max) {
    return max* closeRandom() ;
  }
  float closeRandom(float min, float max) {
    return min + (max - min) * closeRandom();
  }

  float closeRandom(int min, int max) {
    return min + (max - min) * closeRandom();
  }

  float closeRandom(float min, int max) {
    return min + (max - min) * closeRandom();
  }

  /**************************************************
  *Resets the module and creates a new random seed
  **************************************************/
  void reset() {
    randomCount = -3400000;
    countMul = 0;
    noiseSeed = round(random(32000));
    noiseSeed(noiseSeed);
  }
}
