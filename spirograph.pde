//circle cycles
//number of circles
int num = 3;

//modifyable stuffos
float[] radius;
float[] speeds;

//these get calculated
PVector[] centers;

//for display
ArrayList<PVector> points;

int totalPoints = 360*2;

float rate = 3;

int counter;

PVector target;
int hit;
ArrayList<PVector> targetshit;

PFont font;
int currentCirc; //for selecting with arrow keys

void setup(){
  size(1280,720);
  
  font = loadFont("Monospaced-48.vlw");
  textFont(font,15);
  textAlign(CENTER, CENTER);
  currentCirc = 0;
  
  radius = new float[]{50,105,40}; //MODIFY
  
  speeds = new float[]{1,-0.2,1.8}; //MODIFY
  
  for (int i=0; i<radius.length; i++){
    radius[i] = (int)random(30,130);
    speeds[i] = (i+1)*random(0.3,0.8);
  }
  
  points = new ArrayList<PVector>();
  targetshit = new ArrayList<PVector>();
  
  newTarget();
  hit = 0;
  
  centers = new PVector[num];
  for (int i=0; i<centers.length; i++){
    centers[i] = new PVector(width/2,height/1.75);
  }
  
  background(0);
}

void draw(){
  background(0);
  
  noFill();
  
  text("size",40,50);
  for (int i=0; i<3; i++){
    text(str(i+1),100+75*i,50);
    ellipse(100+75*i,50,50,50);
    text(str(radius[i]),100+75*i,100);
  }
  ellipse(100+75*currentCirc,50,40,40);
  
  stroke(255,0,0);
  ellipse(target.x,target.y,50,50);
  ellipse(target.x,target.y,30,30);
  ellipse(target.x,target.y,10,10);
  stroke(255);
  
  float d=counter*rate;
  counter++;
  
  for (int i=1; i<radius.length; i++){
    PVector c = circ(d*speeds[i-1],radius[i-1],centers[i-1]);
    centers[i] = c;
    stroke(255,255,0,100);
    ellipse(c.x,c.y,radius[i]*2,radius[i]*2);
    stroke(255,255,100,150);
    line(centers[i-1].x,centers[i-1].y,centers[i].x,centers[i].y);
  }
  
  //first circle
  stroke(255,255,0,100);
  ellipse(centers[0].x,centers[0].y,radius[0]*2,radius[0]*2);
  //and last line
  stroke(255,255,100,150);
  PVector last = circ(d*speeds[speeds.length-1],radius[radius.length-1],centers[centers.length-1]);
  line (centers[centers.length-1].x,centers[centers.length-1].y, last.x, last.y);
  
  if (dist(last.x,last.y,target.x,target.y) < 50){
    hit ++;
    targetshit.add(target);
    newTarget();
  }
  
  for (int i=0; i<hit; i++){
    stroke(255,150);
    ellipse(width-50-20*i,height-50,5,5);
    stroke(0,150,255,150);
    ellipse(targetshit.get(i).x,targetshit.get(i).y,10,10);
  }
  
  if (points.size()>totalPoints){
    points.remove(0);
  }
  points.add(last);
  
  drawLine();
}

void drawLine(){
  for (int i=1; i<points.size(); i++){
    stroke(255,pow(float(i) / float(points.size()),2) * 255);
    line(points.get(i-1).x,points.get(i-1).y,points.get(i).x,points.get(i).y);
  }
}

void newTarget(){
  target = new PVector(width/2+(int)random(-400,400),height/2+(int)random(-200,200));
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
