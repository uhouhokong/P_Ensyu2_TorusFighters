class SpriteEditor extends Scene{
  PartsParet partsParet;
  SpriteEditor(PApplet parent_){
    parent = parent_;
    partsParet = new PartsParet();
  }
  void startUp(){}
  void update(){
    display();
  }
  void stop(){}
  void display(){
    background(36,21,60);
    partsParet.display();
  }
}
class PartsParet{
  int posX = 320;
  int posY = 0;
  int wid = 320;
  int hig = 200;
  Button[] sButtons = new Button[5];
  Button[] upB;
  Button[] downB;
  int dispPLoc=0;
  int sidelim = 5;
  int lineWid =50;
  ArrayList<AParts> paret = new ArrayList<AParts>();
  PartsParet(){
    sButtons[0] = new Button("aPFo", posX+10,10,40,15);
    sButtons[1] = new Button("aPFi", posX+80,10,40,15);
    sButtons[2] = new Button("aIFi", posX+150,10,40,15);
    sButtons[3] = new Button("<", posX+10,55, 20, 15);
    sButtons[4] = new Button(">", posX+wid-30,55, 20, 15);
  }
  void display(){
    
    
    buttonProcesses();
    
  }
  
  void buttonProcesses(){//♥♥ プロシージャくん
    for(int i=0; i<sButtons.length; i++){
      sButtons[i].display();
    }
    if(sButtons[0].moment){
      selectFolder("フォルダを選んでね", "folderSelected");
      delay(4000);
      println(openedPathBuffer);
      if(openedPathBuffer!=null)addPartsFolder(openedPathBuffer);
    }
  }
  //呼び出しの際にString folderPath()を呼んでopenedFileBuffer.getAbsolutePath()を引数にとったりとらなかったりしろ
  void addPartsFolder(String folderPath){
    String[] buf = folderPath.split("/");
    AParts newParts = new AParts(buf[buf.length-1]);
    paret.add(newParts);
    int j=0;
    PImage nextImage = loadImage(folderPath+"/"+ NumtoString(3, j) + ".png");
    println("try to road \"" +folderPath+"/"+ NumtoString(3, j) + ".png" + "\"");
    while(nextImage!=null){
      newParts.add(nextImage);
      j++;
      nextImage = loadImage(folderPath+"/"+ NumtoString(3, j) + ".png");
      println("try to road \"" +folderPath+"/"+ NumtoString(3, j) + ".png" + "\"");
    }
  }
  void addPartsFile(String filePath){
    AParts newParts = new AParts(paret.size());
    paret.add(newParts);
    PImage nextImage = loadImage(filePath);
    if(nextImage!=null)newParts.add(nextImage);
  }
  
  void addimageFile(int cursol,String filePath){
    AParts newParts = paret.get(cursol);
    PImage nextImage = loadImage(filePath);
    if(nextImage!=null)newParts.add(nextImage);
  }
}

class AParts{
  ArrayList<PImage> images;
  String name;
  int dispILoc;
  AParts(int defaultnum){
    dispILoc=0;
    images = new ArrayList<PImage>();
    name = "パーツ"+defaultnum;
  }
  AParts(String defaultname){
    dispILoc=0;
    images = new ArrayList<PImage>();
    name = defaultname;
  }
  void add(PImage nextImage){images.add(nextImage);}
  int size(){return images.size();}
}//APartsおわり

class Cursol{
  
}

class Button{
  String title;
  int x;
  int y;
  int wid;
  int hig;
  boolean state;
  boolean moment;
  int col;
  
  Button(String title_, int x_, int y_, int wid_, int hig_){
    title = title_;
    x=x_;
    y=y_;
    wid=wid_;
    hig=hig_;
    state=false;
    moment=false;
    col=color(245);
  }
  void display(){
    moment = isPut();
    fill(255);
    stroke(235);
    strokeWeight(1);
    int col_max;
    float ratio;
    if(onButton(mouseX,mouseY)){
      if(state){
        //クリック後、マウスオーバー状態
        col_max=color(218,210,210);
        ratio=0.8;
      }
      else{
        //未クリック、マウスオーバー状態
        col_max=color(240);
        ratio=0.25;
      }
    }
    else {
      //ニュートラルの状態
      col_max=color(255);
      ratio=0.25;
    }
    col=(int)ratioIncreace(col,col_max,ratio);
    fill(col);
    rect(x,y,wid,hig);
    
    textSize(20);
    textAlign(CENTER);
    fill(255-red(col),255-green(col),255-blue(col));
    text(title,x+wid/2+1,y+hig*46/64);
    
  }
  
  boolean isPut(){
    if(momentOfClick==1){
      if(onButton(mouseX,mouseY)){
        state=true;
      }
      else{
        state=false;
      }
    }
    if(momentOfClick==-1){
      if(onButton(mouseX,mouseY)&&state){
        state=false;
        return true;
      }
      state=false;
    }
    return false;
  }
  
  boolean onButton(int x_,int y_){
    if(x_>x&&y_>y&&x_<x+wid&&y_<y+hig)return true;
    return false;
  }
  
  float ratioIncreace(float parametor, float max, float ratio){
    return parametor + (max-parametor)*ratio;
  }
  
  float ratioIncreace(color parametor, color max, float ratio){
    return color(red(parametor) + (red(max)-red(parametor))*ratio,
    green(parametor) + (green(max)-green(parametor))*ratio,
    blue(parametor) + (blue(max)-blue(parametor))*ratio);
  }
}