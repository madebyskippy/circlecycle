//circle cycles
/*
-map out how people will come up to the experience, and the script of what you'll say

-make sure there's good feedback for every input, so it's not too obfuscated and confusing
-good feedback for things achieved so you feel good doing the actions

-maybe make all the circle sizes bigger so each change you make is much more obvious
-that will probably change a lot

-possible: make the goal to get a snowman of a certain size instead of hit a target...
-it's a more clear goal
-then the reward is the pattern the trail makes 

-sound
*/

import processing.serial.*;
// ------------------------- make this true when the arduino is connected
boolean arduino = false;
// -------------------------

Serial myPort;  // Create object from Serial class
int val1;      // Data received from the serial port
int val2;      // Data received from the serial port
int val3;      // Data received from the serial port

//number of circles
int num = 3;
color[] circlecolors = new color[]{ color(250,115,115),
                                    color(117,201,255),
                                    color(183,147,255)};

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

//these get calculated
PVector[] centers;

//for display
ArrayList<PVector> points;
ArrayList<PVector> preview;

int totalPoints = 360*5;

float rate = 2;

int counter;

int level;
boolean solved;

PFont font;
int currentCirc; //for selecting with arrow keys

void setup(){
  if (arduino){
    println(Serial.list());
    String portName = Serial.list()[9];
    myPort = new Serial(this, portName, 9600);
  }
  
  //size(1280,720);
  fullScreen();
  
  solved = false;
  
  font = loadFont("Monospaced-48.vlw");
  textFont(font,15);
  textAlign(CENTER, CENTER);
  currentCirc = 0;
  
  radius = new float[]{50,105,40}; //MODIFY
  
  speeds = new float[]{1,-0.2,1.8}; //MODIFY
  
  level = floor(random(0,lvls.length));
  for (int i=0; i<radius.length; i++){
    //radius[i] = (int)random(100,300);
    radius[i] = lvls[level][0][i]*4;
    speeds[i] = lvls[level][1][i];
  }
  
  points = new ArrayList<PVector>();
  
  centers = new PVector[num];
  for (int i=0; i<centers.length; i++){
    centers[i] = new PVector(width/2,height/1.75);
  }
  
  background(0);
}

void draw(){
  
  if (arduino){
    if ( myPort.available() > 0) {  // If data is available,
      val1 = myPort.read();         // read it and store it in val
      val2 = myPort.read();         // read it and store it in val
      val3 = myPort.read();         // read it and store it in val
      println(val1+","+val2+","+val3);
      radius[0] = lerp(radius[0],30 + 10*val1,0.075);
      radius[1] = lerp(radius[1],30 + 10*val2,0.075);
      radius[2] = lerp(radius[2],30 + 10*val3,0.075);
    }
  }
  
  background(0);
  
  noFill();
  
  text("size",40,50);
  for (int i=0; i<3; i++){
    text(str(i+1),100+75*i,50);
    ellipse(100+75*i,50,50,50);
    text(str(round(radius[i])),100+75*i,100);
  }
  ellipse(100+75*currentCirc,50,40,40);
  
  float d=counter*rate;
  counter++;
  
  for (int i=1; i<radius.length; i++){
    PVector c = circ(d*speeds[i-1],radius[i-1],centers[i-1]);
    centers[i] = c;
    stroke(circlecolors[i],200);
    ellipse(c.x,c.y,radius[i]*2,radius[i]*2);
    
    noStroke();
    fill(circlecolors[i],50);
    ellipse(c.x,c.y,lvls[level][0][i]*8,lvls[level][0][i]*8);
    
    noFill();
    stroke(circlecolors[i-1],150);
    line(centers[i-1].x,centers[i-1].y,centers[i].x,centers[i].y);
  }
  
  //first circle
  stroke(circlecolors[0],200);
  ellipse(centers[0].x,centers[0].y,radius[0]*2,radius[0]*2);    
  noStroke();
  fill(circlecolors[0],50);
  ellipse(centers[0].x,centers[0].y,lvls[level][0][0]*8,lvls[level][0][0]*8);
  
  noFill();
  //and last line
  stroke(circlecolors[2],150);
  PVector last = circ(d*speeds[speeds.length-1],radius[radius.length-1],centers[centers.length-1]);
  line (centers[centers.length-1].x,centers[centers.length-1].y, last.x, last.y);
  
  if (points.size()>totalPoints){
    points.remove(0);
  }
  points.add(last);
  
  drawLine();
}

void drawLine(){
  for (int i=1; i<points.size(); i++){
    stroke(255,232,161,pow(float(i) / float(points.size()),2) * 200);
    line(points.get(i-1).x,points.get(i-1).y,points.get(i).x,points.get(i).y);
  }
}

PVector circ(float deg, float rad, PVector center){
  float x;
  float y;
  x = center.x + rad * cos(radians(deg) +PI/2);
  y = center.y + rad * sin(radians(deg) +PI/2);
  return new PVector(x,y);
}

void checkAnswer(){
  boolean right = true;
  for (int i=0; i<radius.length; i++){
    if (radius[i] != lvls[level][0][i]){
      right = false;
    }
    if (speeds[i] != lvls[level][1][i]){
      right = false;
    }
  }
  solved = right;
}

void keyPressed(){
  if (key == 'r' || key == 'R'){
    setup();
  }
  if (key == CODED) {
    if (keyCode == UP) {
      radius[currentCirc] = min(radius[currentCirc]+1,200);
    } else if (keyCode == DOWN) {
      radius[currentCirc] = max(radius[currentCirc]-1,0);
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
