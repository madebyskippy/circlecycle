//circle cycles
/*
-circle trail so you can tell when you changed it

-sound
*/

import processing.serial.*;
import ddf.minim.*;
// ------------------------- make this true when the arduino is connected
boolean arduino = false;
// -------------------------

Serial myPort;  // Create object from Serial class
int[] vals = new int[3];
int val1;      // Data received from the serial port
int val2;      // Data received from the serial port
int val3;      // Data received from the serial port

Minim minim;
AudioPlayer[] backgNoise = new AudioPlayer[8];
AudioPlayer[] starNoise = new AudioPlayer[8];

//number of circles
int num = 3;
color[] circlecolors = new color[]{ color(250,115,115),
                                    color(117,201,255),
                                    color(183,147,255)};
float[][] circleSizes = new float[3][8];
float[][] circleFades = new float[3][8];
int[] circlePitch = new int[]{0,0,0};

//modifyable stuffos
float[] radius;
float[] speeds;

//levels!!!!!!!!!!!!!!!!!!!
//first index is the level, second is radius / speed, third is the value
//FOR FILLING OUT: first {} on line is radius, second is speed
float[][][] lvls = new float[][][]{{{50,105,40},{1,-.2,1.8}},
                               {{45,110,50},{1.5,-3.,1.4}},
                               {{20,100,50},{1,1.9,-1.9}},
                               {{50,65,50},{1,-1.1,2.2}},
                               {{60,60,50},{1,-.2,2.2}},
                               {{80,30,55},{1,-1.4,-3}},
                               {{50,30,40},{1,.1,-2.6}},
                               {{50,105,40},{1,.1,-2.6}},
                               {{100,50,25},{1,-2.1,-2.1}},
                               {{100,50,50},{1,1,2.9}}};
                               
int level;

//these get calculated
PVector[] centers;

//for display
ArrayList<PVector> points;
ArrayList<PVector> preview;

int totalPoints = 360;

float rate = 2;

int counter;

PVector target;
float targetSize = 1;
int targetSizeDirection = 1;
int hit;
ArrayList<PVector> targetshit;
ArrayList<PVector> targetshitSize;

PFont font;
int currentCirc; //for selecting with arrow keys

void setup(){
  if (arduino){
    println(Serial.list());
    String portName = Serial.list()[7];
    myPort = new Serial(this, portName, 9600);
  }
  
  //size(1280,720);
  fullScreen();
  
  minim = new Minim(this);
  for (int i=0; i<8; i++){
    backgNoise[i] = minim.loadFile("hit"+str(i+1)+".mp3");
    starNoise[i] = minim.loadFile("side"+str(i+1)+".mp3");
  }
  
  font = loadFont("Monospaced-48.vlw");
  textFont(font,15);
  textAlign(CENTER, CENTER);
  
  currentCirc = 0;
  
  radius = new float[]{50,105,40}; //MODIFY
  
  speeds = new float[]{1,-0.2,1.8}; //MODIFY
  
  level = floor(random(0,lvls.length));
  for (int i=0; i<radius.length; i++){
    radius[i] = (int)random(100,300);
    //radius[i] = lvls[level][0][i]*4;
    speeds[i] = lvls[level][1][i];
    for (int j=0; j<circleSizes[i].length; j++){
      circleSizes[i][j] = radius[i];
      circleFades[i][j] = 0f;
    }
  }
  
  points = new ArrayList<PVector>();
  targetshit = new ArrayList<PVector>();
  targetshitSize = new ArrayList<PVector>();
  
  newTarget();
  hit = 0;
  
  centers = new PVector[num];
  for (int i=0; i<centers.length; i++){
    centers[i] = new PVector(width/2,height/2);
  }
  
  background(0);
  
  strokeWeight(3);
}

void reset(){
  textFont(font,15);
  textAlign(CENTER, CENTER);
  
  currentCirc = 0;
  
  level = floor(random(0,lvls.length));
  for (int i=0; i<radius.length; i++){
    radius[i] = (int)random(100,300);
    //radius[i] = lvls[level][0][i]*4;
    speeds[i] = lvls[level][1][i];
    for (int j=0; j<circleSizes[i].length; j++){
      circleSizes[i][j] = radius[i];
      circleFades[i][j] = 0f;
    }
  }
  
  points = new ArrayList<PVector>();
  targetshit = new ArrayList<PVector>();
  targetshitSize = new ArrayList<PVector>();
  
  newTarget();
  hit = 0;
  
  centers = new PVector[num];
  for (int i=0; i<centers.length; i++){
    centers[i] = new PVector(width/2,height/2);
  }
  
  background(0);
  
  strokeWeight(3);
}

void draw(){
  //get arduino values
  if (arduino){
    if ( myPort.available() > 0) {  // If data is available,
      val1 = myPort.read();         // read it and store it in val
      val2 = myPort.read();         // read it and store it in val
      val3 = myPort.read();         // read it and store it in val
      if (val1<100){
        vals[0] = val1;
      }
      if (val2 >= 100 && val2 < 200){
        vals[1] = val2-100;
      }
      if (val3 >= 200){
        vals[2] = val3-200;
      }
      //println(val1+","+val2+","+val3);
      int direction = 1;
      for (int i=0; i<3; i++){
        if ((100 + 20*vals[i])>radius[i]){
          radius[i] = min(radius[i] + 4,(100 + 20*vals[i]));
        }
        if ((100 + 20*vals[i])<radius[i]){
          radius[i] = max(radius[i] - 4,(100 + 20*vals[i]));
        }
      }
    }
  }
  
  //get circle trail
  for (int i=0; i<3; i++){
    if (abs(radius[i]-circleSizes[i][0]) > 10){
      for (int j=circleSizes[i].length-1; j>0; j--){
        circleSizes[i][j] = circleSizes[i][j-1];
        circleFades[i][j] = circleFades[i][j-1];
      }
      circleSizes[i][0] = radius[i];
      circleFades[i][0] = 1f;
    }
  }
  
  background(0);
  
  noFill();
  
  float d=counter*rate;
  counter++;
  
  //find updated centers of circles
  for (int i=1; i<radius.length; i++){
    PVector c = circ(d*speeds[i-1],radius[i-1],centers[i-1]);
    centers[i] = c;
  }
  
  //find latest path point
  PVector last = circ(d*speeds[speeds.length-1],radius[radius.length-1],centers[centers.length-1]);
  
  //check if you hit the target
  if (dist(last.x,last.y,target.x,target.y) < 50){
    int soundIndex = (int)((float)(target.y-(height/2-400))/(float)(800f/3f));
    soundIndex += (int)((float)(target.x-(width/2-600))/(float)(1200f/3f));
    starNoise[soundIndex].rewind();
    starNoise[soundIndex].play();
    
    hit ++;
    targetshit.add(target);
    int tw = (int)random(5,30);
    int th = tw + (int)random(5,30);
    targetshitSize.add(new PVector(tw,th));
    newTarget();
    
    if (hit > 20){
      reset();
    }
  }
  
  //dead stars
  int w;
  int h;
  for (int i=0; i<hit; i++){
    //ellipse(width-50-20*i,height-50,5,5);
    stroke(255,50);
    w = (int)targetshitSize.get(i).x;
    h = (int)targetshitSize.get(i).y;
    //ellipse(targetshit.get(i).x,targetshit.get(i).y,10,10);
    arc(targetshit.get(i).x-w,targetshit.get(i).y-h,w*2,h*2,0,HALF_PI);
    arc(targetshit.get(i).x+w,targetshit.get(i).y-h,w*2,h*2,HALF_PI,HALF_PI*2);
    arc(targetshit.get(i).x+w,targetshit.get(i).y+h,w*2,h*2,HALF_PI*2,HALF_PI*3);
    arc(targetshit.get(i).x-w,targetshit.get(i).y+h,w*2,h*2,HALF_PI*3,HALF_PI*4);
  }
  
  //update path list
  if (points.size()>totalPoints){
    points.remove(0);
  }
  points.add(last);
  
  //draw circle trails
  strokeWeight(1);
  for (int i=0; i<3; i++){
    for (int j=1; j<circleSizes[i].length; j++){
      stroke(circlecolors[i],175*(1-pow((float)j/(float)circleSizes[i].length,2))*circleFades[i][j]);
      ellipse(centers[i].x,centers[i].y,circleSizes[i][j]*2,circleSizes[i][j]*2);
      circleFades[i][j] *= 0.95f;
    }
  }
  strokeWeight(3);
  
  drawCircle(0);
  drawCircle(1);
  drawCircle(2);
  
  //draw star on end of 3 circles
  stroke(255,232,161);
  arc(last.x-10,last.y-20,20,40,0,HALF_PI);
  arc(last.x+10,last.y-20,20,40,HALF_PI,HALF_PI*2);
  arc(last.x+10,last.y+20,20,40,HALF_PI*2,HALF_PI*3);
  arc(last.x-10,last.y+20,20,40,HALF_PI*3,HALF_PI*4);
  
  //draw target
  stroke(255);
  targetSize = targetSize - 0.01 * targetSizeDirection;
  if (targetSize < 0.75 || targetSize > 1){
    targetSizeDirection *= -1;
  }
  w=(int)(30*targetSize);
  h=(int)(50*targetSize);
  arc(target.x-w,target.y-h,w*2,h*2,0,HALF_PI);
  arc(target.x+w,target.y-h,w*2,h*2,HALF_PI,HALF_PI*2);
  arc(target.x+w,target.y+h,w*2,h*2,HALF_PI*2,HALF_PI*3);
  arc(target.x-w,target.y+h,w*2,h*2,HALF_PI*3,HALF_PI*4);
  ellipse(target.x,target.y,10,10);
  
  //draw path
  drawPath();
}

void drawPath(){
  for (int i=1; i<points.size(); i++){
    stroke(255,232,161,float(i) / float(points.size()) * 100);
    line(points.get(i-1).x,points.get(i-1).y,points.get(i).x,points.get(i).y);
  }
}

void drawCircle(int i){
  stroke(circlecolors[i],200);
  ellipse(centers[i].x,centers[i].y,radius[i]*2,radius[i]*2);    
  
  noFill();
  stroke(circlecolors[i],150);
  if (i>=2){
    line (centers[i].x,centers[i].y, points.get(points.size()-1).x,points.get(points.size()-1).y);
  }else{
    line(centers[i].x,centers[i].y,centers[i+1].x,centers[i+1].y);
  }
  
  int pitch = constrain((int)((max(radius[i],100)-100)/(200f/4f)),0,3);
  if (pitch != circlePitch[i]){
    circlePitch[i] = pitch;
    backgNoise[i*2+circlePitch[i]].rewind();
    backgNoise[i*2+circlePitch[i]].play();
  }
}

void newTarget(){
  target = new PVector(width/2+(int)random(-600,600),height/2+(int)random(-400,400));
}

PVector circ(float deg, float rad, PVector center){
  float x;
  float y;
  x = center.x + rad * cos(radians(deg) +PI/2);
  y = center.y + rad * sin(radians(deg) +PI/2);
  return new PVector(x,y);
}

void keyPressed(){
  if (key == 'r' || key == 'R'){
    reset();
  }
  if (key == CODED) {
    if (keyCode == UP) {
      radius[currentCirc] = min(radius[currentCirc]+4,300);
    } else if (keyCode == DOWN) {
      radius[currentCirc] = max(radius[currentCirc]-4,10);
    } else if (keyCode == LEFT) {
      if (currentCirc == 0){
        currentCirc = 2;
      }else{
        currentCirc --;
      }
    } else if (keyCode == RIGHT) {
      currentCirc = (currentCirc+1)%3;
    }
  }
}
