// ************************************ IMAGES & VIDEO 
int pictureCounter=0, frameCounter=0;
Boolean filming=false, change=false;
PImage myFace; // picture of author's face, should be: data/pic.jpg in sketch folder
void snapPicture() {saveFrame("PICTURES/P"+nf(pictureCounter++,3)+".jpg"); }

// ******************************************COLORS 
color black=#000000, white=#FFFFFF, // set more colors using Menu >  Tools > Color Selector
   red=#FF0000, green=#00FF01, blue=#0300FF, yellow=#FEFF00, cyan=#00FDFF, magenta=#FF00FB,
   grey=#818181, orange=#FFA600, brown=#B46005, metal=#B5CCDE, dgreen=#157901;
void pen(color c, float w) {stroke(c); strokeWeight(w);}

// ******************************** TEXT , TITLE, and USER's GUIDE
Boolean scribeText=true; // toggle for displaying of help text
void scribe(String S, float x, float y) {fill(0); text(S,x,y); noFill();} // writes on screen at (x,y) with current fill color
void scribeHeader(String S, int i) {fill(0); text(S,10,20+i*20); noFill();} // writes black at line i
void scribeHeaderRight(String S) {fill(0); text(S,width-7.5*S.length(),20); noFill();} // writes black on screen top, right-aligned
void scribeFooter(String S, int i) {fill(0); text(S,10,height-10-i*20); noFill();} // writes black on screen at line i from bottom
void scribeAtMouse(String S) {fill(0); text(S,mouseX,mouseY); noFill();} // writes on screen near mouse
void scribeMouseCoordinates() {fill(black); text("("+mouseX+","+mouseY+")",mouseX+7,mouseY+25); noFill();}

//***********
//Addtional code to implement Collsion time calculation
//**********
//All the code below have been written by Bhuvanesh Shanmuga Sundaram

//To store the details of collision events like Time to collision, ball1 id and ball2 id.
class CollisionEvent{
  int Ball1, Ball2;
  float Ttc; //time_to_collision
  CollisionEvent(float ttc, int ball1, int ball2){
    Ball1 = ball1;
    Ball2 = ball2;
    Ttc = ttc;
  }
  void decrementTtc(){
    this.Ttc = this.Ttc - 2*u; 
  }
  boolean isCollided(){
    if(this.Ttc <= 3*u)
      return true;
    else 
      return false;
  }
  void updatePostCollisionVelocity(){
    vec v1 = new vec(P.V[Ball1].x, P.V[Ball1].y, P.V[Ball1].z); 
    vec v2 = new vec(P.V[Ball2].x, P.V[Ball2].y, P.V[Ball2].z);
    vec a = new vec(P.G[Ball1].x, P.G[Ball1].y, P.G[Ball1].z);
    vec b = new vec(P.G[Ball2].x, P.G[Ball2].y, P.G[Ball2].z);
    vec BA = M(a,b); // B-A
    vec unitNormalVec = U(BA); //  BA/||BA||
    vec u1 = V(dot(v1,unitNormalVec),unitNormalVec);
    //vec u1 = V(dot(v1,V(-1,unitNormalVec)),unitNormalVec);  // u1 = (v1.Normal)Normal   normal component of v1
    vec u2 = V(dot(v2,unitNormalVec),unitNormalVec);  // normal component of v2
    
    vec w1 = M(v1,u1);
    w1 = A(w1,u2);
    vec w2 = M(v2,u2);
    w2 = A(w2,u1);
    /*
    println("Balls:"+Ball1+" "+Ball2);
    println("unit nomal:"+unitNormalVec.x+","+unitNormalVec.y+","+unitNormalVec.z);
    println("v1:"+v1.x+","+v1.y+","+v1.z+"; v2:"+v2.x+","+v2.y+","+v2.z);
    println("u1:"+u1.x+","+u1.y+","+u1.z+"; u2:"+u2.x+","+u2.y+","+u2.z);
    println("w1:"+w1.x+","+w1.y+","+w1.z+"; w2:"+w2.x+","+w2.y+","+w2.z);
    */
  }
}

ArrayList<CollisionEvent> CEvents = new ArrayList<CollisionEvent>(1000); //Array list to store the event objects 
float FirstCollisionTime=0;
  
//Decrements Time to collision every frame
void CEventsDecrementTtc(){
  for(CollisionEvent ce:CEvents){
    ce.decrementTtc();
  }
}

//Inserts the events in the increasing order of Time to collision in the events list
void CEventsSortedInsert(CollisionEvent ce){
  for (int i=0 ; i<CEvents.size(); i++) {
    if(CEvents.get(i).Ttc > ce.Ttc){
      CEvents.add(i,ce);
      return;
    }
  }
  CEvents.add(ce);
  FirstCollisionTime = CEvents.get(0).Ttc;
}

//Function to check if any of the collision is about to takeplace before the next frame
void CEventsCheckCollided(){
  boolean collisionHappens = false;
  int m=0;
  int i=0;
  for ( ; i<CEvents.size(); i++) {
    if(CEvents.get(i).isCollided()){
      collisionHappens = true;
      if(CEvents.get(i).Ball2!=-1){
         CEvents.get(i).updatePostCollisionVelocity();
      }
      m++;
    }
  }
  if(collisionHappens == true){
    println(m+" collidings");
    CEvents.clear();
    //Animation is stopped on first detected collision
    //animating=!animating; 
  }
}

//Funciton to calculate the ball-ball collision time
float calcBallCollisionTime(int a, int b){
  float r = P.r[a];
  /*Shortened version*/
  /*vec a0a1 = new vec(P.G[b].x-P.G[a].x,P.G[b].y-P.G[a].y,P.G[b].z-P.G[a].z);
  vec v0v1 = new vec(P.V[b].x-P.V[a].x,P.V[b].y-P.V[a].y,P.V[b].z-P.V[a].z);
  float t1 = (-1*a0a1.norm() + 2*r)/v0v1.norm();
  float t2 = (-1*a0a1.norm() - 2*r)/v0v1.norm();
  if(!Float.isNaN(t1)){
    if(t1>=0 && t2>=0){
        return t1<t2?t1:t2;
    }else if(t1>0) return t1;
    else if(t2>0) return t2;
    else return -1;
  }else return -1;*/
  
  /*Original Formula*/
  
  vec a0a1 = new vec(P.G[b].x-P.G[a].x,P.G[b].y-P.G[a].y,P.G[b].z-P.G[a].z);
  vec v0v1 = new vec(P.V[b].x-P.V[a].x,P.V[b].y-P.V[a].y,P.V[b].z-P.V[a].z);
  float P = v0v1.x*v0v1.x + v0v1.y*v0v1.y + v0v1.z*v0v1.z;
  float Q = a0a1.x*v0v1.x + a0a1.y*v0v1.y + a0a1.z*v0v1.z;
  float R = a0a1.x*a0a1.x + a0a1.y*a0a1.y + a0a1.z*a0a1.z;
  float d = 4*Q*Q - 4*P*(R-4*r*r);
  if(d>0){
    float t1 = ((-2)*Q+sqrt(d))/(2*P);
    float t2 = ((-2)*Q-sqrt(d))/(2*P);
    if(t1>=0 && t2>=0){
      return t1<t2?t1:t2;
    }else if(t1>0) return t1;
    else if(t2>0) return t2;
    else return -1;
  }else{
    return -1;
  }
}

//Function to calculate Ball-Wall collision time
float calcWallCollisionTime(int i){
  float w = 200 - P.r[i];
  float time = 9999;
  float tx = (w-P.G[i].x)/P.V[i].x;
  if(tx>=0 && tx<time) time = tx;
  float ty = (w-P.G[i].y)/P.V[i].y;
  if(ty>=0 && ty<time) time = ty;
  float tz = (w-P.G[i].z)/P.V[i].z;
  if(tz>=0 && tz<time) time = tz;
  w = -1*w;
  float tnx = (w-P.G[i].x)/P.V[i].x;
  if(tnx>=0 && tnx<time) time = tnx;
  float tny = (w-P.G[i].y)/P.V[i].y;
  if(tny>=0 && tny<time) time = tny;
  float tnz = (w-P.G[i].z)/P.V[i].z;
  if(tnz>=0 && tnz<time) time = tnz;
  if(time!=9999) return time;
  else return -1;
}

//functions for visual debugging
void ShowConnections(){
  for(CollisionEvent ce:CEvents){
    if(ce.Ball2!=-1)
      show(P.G[ce.Ball1],P.G[ce.Ball2]);
  }
}
void ShowBallNumbers(){
  scribe("hellos", 10,10);
  for(int i=0;i<nbs*nbs*nbs;i++){
    pt p = ToScreen(P.G[i]);
    scribe(i+"?",screenX(p.x,p.y,p.z),screenY(p.x,p.y,p.z));
  }
}