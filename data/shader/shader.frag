#ifdef GL_ES

precision highp float;

#endif

uniform vec2 resolution;

uniform float time;

uniform vec2 mouse;

uniform int pointX[4];

uniform int pointY[4];

uniform int size;

uniform int Glow[4];

vec4 f = vec4(1.,1.,1.,1.); // f will be used to store the color of the current fragment

float shine = 1.0;

void main(void)

{    

 vec2 c = vec2 (-1.0 + 2.0 * gl_FragCoord.x / resolution.x, 1.0 - 2.0 * gl_FragCoord.y / resolution.y) ;

 vec2 mousepos = vec2(-1.0 + 2.0 * mouse.x / resolution.x,-1.0 + 2.0 * mouse.y / resolution.y);
	int count = 0;
	float max_d = 0;
	float d =0;
	bool yes = false;
for(int i=0;i<4;i++){	
 if(yes == true){
	break;
 }
 float x = pointX[i]-gl_FragCoord.x;
 float y = -(resolution.y-pointY[i])+gl_FragCoord.y;
 
 d = sqrt(x*x+y*y);
 
 if(d<size*1.41){
	if(abs(x)<size/2 && abs(y)<size/2){
		yes = true;
		count = i;
	}
 }
	
	max_d = max_d+(1/pow(d,0.9))*Glow[i]/255;
 }
  
 float mul = min(0.0000045*(resolution.x*resolution.y)*max_d,255);
 
 
	mul=mul*mul;
	if (yes ==true){
		mul = 1.0 * Glow[count]/255;
	}
 
 vec2 s = vec2(sin(gl_FragCoord.x*0.1),sin(gl_FragCoord.y*0.1));
 
 f = vec4(shine*mul, shine*mul, shine*mul, 1.0);  // This is the code you see in the tutorial   

 gl_FragColor = f;

}