import SimpleOpenNI.*;

SimpleOpenNI  context;
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };
PVector com = new PVector();                                   
PVector com2d = new PVector();                                   
float xoff;
float distanceScalar;

void setup()
{
  size(1280, 960, P3D);
  
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  // enable depthMap generation 
  context.enableDepth();
   
  // enable skeleton generation for all joints
  context.enableUser();
 
  background(255,255,255);

  stroke(0,0,255);
  strokeWeight(3);
  smooth();  
}

void draw()
{
  stroke(0);
  for (int i=0; i<100; i++) {
    line(random(width),random(height),random(width),random(height));
  }
  
  // update the cam
  context.update();
  
  // draw depthImageMap
  //image(context.depthImage(),0,0);
  //image(context.userImage(),0,0);
  //background(255,255,255);
  background(0);

  
  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    if(context.isTrackingSkeleton(userList[i]))
    {
      //stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      //strokeWeight(20);
      //drawSkeleton(userList[i]);
    }      

    // get 3D position of a joint
    PVector jointPos = new PVector();
    context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_TORSO, jointPos);
    
    // convert real world point to projective space
    PVector jointPos_Proj = new PVector(); 
    context.convertRealWorldToProjective(jointPos,jointPos_Proj);
    
    PVector jointPosLeftHand = new PVector();
    PVector jointPosRightHand = new PVector();
    PVector jointPos_ProjLeftHand = new PVector(); 
    PVector jointPos_ProjRightHand = new PVector(); 
    context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_LEFT_HAND, jointPosLeftHand);
    context.getJointPositionSkeleton(userList[i], SimpleOpenNI.SKEL_RIGHT_HAND, jointPosRightHand);
    context.convertRealWorldToProjective(jointPosLeftHand, jointPos_ProjLeftHand);
    context.convertRealWorldToProjective(jointPosRightHand, jointPos_ProjRightHand);
    
    // create a distance scalar related to the depth (z dimension)
    distanceScalar = (512/jointPos_Proj.z);
    
    //get width factor of hands 
    float distanceOfHands;
    distanceOfHands = jointPos_ProjRightHand.x - jointPos_ProjLeftHand.x;
    if (distanceOfHands<=0) distanceOfHands =0.3;
    
    distanceOfHands = map(distanceOfHands, 0, 500, 0.2, 4 );
    println(distanceOfHands);
    

    //draw lines
    if(context.getCoM(userList[i],com))
    {
      context.convertRealWorldToProjective(com, com2d);    
      float posX = com2d.x *2.5;
      float posY = com.y; 
      
      stroke(178, 34, 34);
      
      xoff = xoff + .02;
      float n = noise(xoff) * width/10 * distanceOfHands;
      
      strokeWeight(n);
      
      beginShape(LINES);
        
       vertex(width-com2d.x *2.5, 0);
       vertex(width-com2d.x *2.5, com.y + 1500);
       
      endShape();
      
      fill(0,255,100);
    }  
  }
  
//*
      noStroke();
      int gridSize = 120;
      float n = noise(xoff) * width/5 * (distanceScalar+2);
       
      for (int x = gridSize; x <= width - gridSize; x += gridSize) {
        for (int y = gridSize; y <= height - gridSize; y += gridSize) {
          noStroke();
          fill(255);
          //rect(x-1, y-1, 6, 6);
          ellipse(x-1, y-1, 6, 6);
          stroke(255, 50);
          //line(x, y, width/2, height/2);
        }
      }
//*/
  
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }
}  

boolean sketchFullScreen() {
  return true;
}
