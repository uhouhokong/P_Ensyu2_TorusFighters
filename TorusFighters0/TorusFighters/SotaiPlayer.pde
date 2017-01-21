//担当:大曽根
//キャラクターに関するクラス

class SotaiPlayer extends Player{
  //各状態の画像枚数
  int [] frameList ={1,1,7,1,16,1,1,1,1,1,3,2,0,1,1,0,3,2,2,4,4,6};
  
  SotaiPlayer(){
  state = new SotaiIdolState(this);
  loadImages();
  }
  
  
  void loadImages(){
    images = new PImage[2][frameList.length][];
    if(frameList.length!=images[0].length){
      println("dismatching frameList.length:"+frameList.length+" to images[0].length:"+images[0].length);
      int[] er = new int[1];
      er[100]=0;
    }
    for(int i = 0; i < images[0].length; i++){
      images[0][i] = new PImage[frameList[i]];
      images[1][i] = new PImage[frameList[i]];
      println(i);
    }
    
    int cnt = 0;
    for(int i = 0; i < images[0].length; i++){
      for(int j = 0; j < images[0][i].length; j++){
      images[0][i][j] = loadImage("../../image/Sotai/sotai/"+ NumtoString(3, cnt) + ".png");
      images[1][i][j] = loadImage("../../image/Sotai/sotai_/"+ NumtoString(3, cnt) + ".png");
      cnt++;
      }
    }
  }
  
  //振る舞いを関数として提供、act[英単語]()の形で
  //コマンド技の関数
  void actTatakituke(){
    float cx_=direction*wid*2/3;
    float cy_=-hig/5;
    int wid_=wid;
    int hig_=hig/3;
    
    Collider newCollider = new Collider(stage, this, direction, 2, 20, wid/2+cx_ , hig/2+cy_, wid_, hig_, -1, true, false);
    stage.colliderList.add(newCollider);
  }
  //派生技の関数
  void actApper(){
    float cx_=direction*wid*2/3;
    float cy_=-hig/5;
    int wid_=wid;
    int hig_=hig/3;
    
    Collider newCollider = new Collider(stage, this, direction, 2, 30, wid/2+cx_ , hig/2+cy_, wid_, hig_, -1, true, false);
    stage.colliderList.add(newCollider);
  }
  //パンチ用の関数
  void actPunch(){
    addCollider(direction*wid*2/3, -hig/5, wid, hig/3, -1);}
  //キック用の関数
  void actKick(){
    addCollider(direction*wid*2/3, hig/5, wid*3/2, hig/3, -1);}
  void actDurKick(){
    vx=0;}
    //反転用の関数
  void actFlip(){
    direction=-direction;
    addCollider(direction*(wid/2), 0, wid/2, hig, -1);}
    //飛び蹴り用の関数
  void actJumpKick(){
    addCollider(direction*wid*2/3, hig*3/5, wid*3/2, hig/1, -1);}
  void actTripped(){
    addCollider(direction*wid*2/3, hig*3/5, wid*3/2, hig/1, -1);}
   //飛び道具用の関数
  void actShootBullet(){
    addBullet(direction*wid*2/3, 0, wid*2/3, hig/3, 140, direction*1.8, 0);
  }
  //回転蹴り用の関数
  void actWhirlwindKick(){
    vy = -VY0/3;
    addCollider(direction*wid*2/3, hig/5, wid*2/3, hig/3, -1);
    addCollider(-direction*wid*2/3, hig/5, wid*2/3, hig/3, -1);
  }
   void beHeld(){//全部に実装
    changeState(new SotaiBeHeldState(this));
  }
  void beFree(){//全部に実装
    changeState(new SotaiLandState(this));
  }
  void getDamage(Collider other){//全部に実装
    if(state instanceof SotaiCounterWaitState){
      if(other instanceof Bullet){
        changeState(new SotaiCounterBulletState(this,(Bullet)other));
      }
    }
    else{
      super.getDamage(other);
    }
}