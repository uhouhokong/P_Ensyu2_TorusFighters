//テスト用キャラ、他キャラクターの下位互換なので説明は省略
//担当:森口

class PlainPlayer extends Player{
  int [] frameList ={1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,2};
  
  PlainPlayer(){
  name = "Plain";
  state = new PlainIdolState(this);
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
    }
    
    int cnt = 0;
    for(int i = 0; i < images[0].length; i++){
      for(int j = 0; j < images[0][i].length; j++){
      images[0][i][j] = loadImage("../../image/素体雑ex/"+ NumtoString(3, cnt) + ".png");
      images[1][i][j] = loadImage("../../image/素体雑ex_/"+ NumtoString(3, cnt) + ".png");
      cnt++;
      }
    }
  }
  
  //振る舞いを関数として提供、act[英単語]()の形で
  
  void actPunch(){
    addCollider(direction*wid*2/3, -hig/5, wid, hig/3, -1);}
  void actKick(){
    addCollider(direction*wid*2/3, -hig/5, wid*3/2, hig/3, -1);}
  void actDurKick(){
    vx=0;}
  void actFlip(){
    direction=-direction;
    addCollider(direction*(wid/2), 0, wid/2, hig, -1);}
  void actJumpKick(){
    addCollider(direction*wid*2/3, hig*3/5, wid*3/2, hig/1, -1);}
  void actTripped(){
    addCollider(direction*wid*2/3, hig*3/5, wid*3/2, hig/1, -1);}
  void actShootBullet(){
    addBullet(direction*wid*2/3, 0, wid*2/3, hig/3, 140, direction*1.8, 0);
  }
  void actShootBack(){
    addBullet(-direction*wid*2/3, 0, wid*2/3, hig/3, 140, -direction*2.2, 0);
  }
  void actWhirlwindKick(){
    vy = -VY0/3;
    addCollider(direction*wid*2/3, hig/5, wid*2/3, hig/3, -1);
    addCollider(-direction*wid*2/3, hig/5, wid*2/3, hig/3, -1);
  }
  void beHeld(){//全部に実装
    changeState(new PlainBeHeldState(this));
  }
  void beFree(){//全部に実装
    changeState(new PlainLandState(this));
  }
  void getDamage(Collider other){//全部に実装
    /*if(state instanceof PlainCounterWaitState){
      if(other instanceof Bullet){
        changeState(new PlainCounterBulletState(this,(Bullet)other));
      }
    }
    else{
      super.getDamage(other);
    }*/
    super.getDamage(other);
  }
}

/************状態クラスの雛形（コピペ用）***********
class Plain__State extends PlainState{
  Plain__State(PlainPlayer player_){
    player = player_;
    no = 0;//状態の通し番号
    count = 0;
    limit =-1;//状態が終了するまでの時間を指定、-1だと無限
  }
  void startUp(){
    //player.act__();
  }
  
  void update(int[] keyState){
    countUp();//カウントする この処理は必ず行う
    if(damageBrunching(0))return;
    
    //player.act__();
    if(count==limit){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    //いずれかの行を追加する
    //return straightAnimation(images, 3);
    //return loopAnimation(images, 3);
    //return fullAnimation(images);
  }
}

*/
//***********状態クラスの説明***********
class Plain__State extends PlainState{
  Plain__State(PlainPlayer player_){
    player = player_;
    no = 0;//状態の通し番号
    count = 0;
    limit =-1;//状態が終了するまでの時間を指定、-1だと無限
  }
  void startUp(){
    //開始時の処理を以下のように書く
    //player.act__();
  }
  
  void update(int[] keyState){
    countUp();//カウントする この処理は必ず行う
    if(damageBrunching(0))return;//ダメージ時の分岐を行うときこの行を追加しておく
    //通常は引数に0、大げさにダメージを受けたいとき1を指定、
    //また、被ダメージ状態に移行しないときこの行を削除する
    
    //ループ時の処理を以下のように書く
    //player.act__();
    
    //指定した状態に変遷する時は条件分岐＋changeState()で行う
    //changeState(new Plain__State(player));の直後にreturn;しておくと
    //意図しない状態に変遷することがなく安全
    
    if(keyState[4]==1){
      changeState(new PlainPunchState(player));return;
    }
    
    //ループを脱するときの処理を以下のように書く
    if(count==limit){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    //いずれかの行を追加する
    return straightAnimation(images, 3);
    //return loopAnimation(images, 3);
    //return fullAnimation(images);
  }
}

//
class PlainState extends State{
  PlainPlayer player;
  void changeState(State nextState){
    if(nextState==null)return;
    player.changeState(nextState);
  
  }
  State commandBrunching(){
    if(player.keyState[4]!=1)return null;
    Integer[] input = player.command.now();
    
    if(commandDetection(input, 1+player.direction, 1, 1-player.direction)){//コマンド入力リストの後ろから
      return new PlainShootBulletState(player);
    }
    if(commandDetection(input, 1-player.direction, 1, 1+player.direction)){//コマンド入力リストの後ろから
      return new PlainShootBackState(player);
    }
    return null;
    
  }
  
  void defaultBrunching(){
    if(player.stateBuffer!=null){
      changeState(player.stateBuffer);
      player.stateBuffer=null;
      player.stateBufCount=-1;
    }
    else if(player.isGrounding==0){
      changeState(new PlainJumpState(player));
    }
    else if(player.keyState[0]>0 && player.keyState[2]==0){//右キー入力
      if(player.direction==-1 && player.isConfronting)changeState(new PlainGuardState(player));
      else changeState(new PlainWalkState(player));
    }
    else if(player.keyState[0]==0 && player.keyState[2]>0){//左キー入力
      if(player.direction== 1 && player.isConfronting)changeState(new PlainGuardState(player));
      else changeState(new PlainWalkState(player));
    }
    else if(player.keyState[1]>0){
    changeState(new PlainSquatState(player));
    }
    else if(player.keyState[3]>0){
    changeState(new PlainJumpState(player));
    }
    else{
      changeState(new PlainIdolState(player));
    }
  }
  boolean damageBrunching(int receiveType){
    if(player.damaged==0)return false;
    if(player.isGrounding==0)receiveType++;
    println("damaged:" + (player.damaged+receiveType));
    switch(max(0,min(player.damaged+receiveType,2))){
      case 0:changeState(new PlainGuardRigorState(player));return true;
      case 1:changeState(new PlainBeHitLState(player));return true;
      case 2:changeState(new PlainBeHitLState(player));return true;
    }
    return false;
  }
}

class PlainIdolState extends PlainState{
  PlainIdolState(PlainPlayer player_){
    player = player_;
    no = 3;
    count = 0;
    limit = -1;
  }
  
  void startUp(){
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    if(commandBrunching()!=null){changeState(commandBrunching());return;}
    
    if(player.keyState[0]>0 && player.keyState[2]==0){//右キー入力
      if(player.direction==-1 && player.isConfronting){changeState(new PlainGuardState(player));return;}
      else changeState(new PlainWalkState(player));
    }
    else if(player.keyState[0]==0 && player.keyState[2]>0){//左キー入力
      if(player.direction== 1 && player.isConfronting){changeState(new PlainGuardState(player));return;}
      else changeState(new PlainWalkState(player));
    }
    else{
      //player.actNoMove();
    }
    
    if(keyState[1]>1){
      changeState(new PlainSquatState(player));return;
    }
    if(keyState[3]==1){
      changeState(new PlainJumpState(player));return;
    }
    
    if(keyState[4]==1){
      changeState(new PlainPunchState(player));return;
    }
    if(keyState[5]==1){
      changeState(new PlainFlipState(player));return;
    }
  }
  PImage drawSprite(PImage[] images){
    return loopAnimation(images, 3);
  }
}

class PlainWalkState extends PlainState{
  PlainWalkState(PlainPlayer player_){
    player = player_;
    no = 4;
    count = 0;
    limit = -1;
  }
  void startUp(){
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    if(commandBrunching()!=null){changeState(commandBrunching());return;}
    if(keyState[0]>0 && keyState[2]==0){
      if(player.direction==-1 && player.isConfronting){changeState(new PlainGuardState(player));return;}
      player.actMoveRight();
    }
    else if(keyState[0]==00 && keyState[2]>0){
      if(player.direction== 1 && player.isConfronting){changeState(new PlainGuardState(player));return;}
      player.actMoveLeft();
    }
    
    else {
      changeState(new PlainIdolState(player));return;}
    
    if(keyState[1]>1){
      changeState(new PlainSquatState(player));return;
    }
    if(keyState[3]==1){
      changeState(new PlainJumpState(player));return;
    }
    
    if(keyState[4]==1){
      changeState(new PlainKickState(player));return;
    }
    if(keyState[5]==1){
      changeState(new PlainFlipState(player));return;
    }
  }
  PImage drawSprite(PImage[] images){
    return loopAnimation(images, 3);
  }
}

class PlainGuardState extends PlainState{
  PlainGuardState(PlainPlayer player_){
    player = player_;
    no = 6;
    count = 0;
    limit = -1;
  }
  void startUp(){
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(-1))return;
    player.isGuard = false;
    if(commandBrunching()!=null){changeState(commandBrunching());return;}
    if(keyState[0]>0 && keyState[2]==0){
      if(player.direction==-1 && player.isConfronting){}
    }
    else if(keyState[0]==00 && keyState[2]>0){
      if(player.direction== 1 && player.isConfronting){}
    }
    
    else {
      changeState(new PlainIdolState(player));return;}
    
    if(keyState[1]>1){
      changeState(new PlainSquatState(player));return;
    }
    if(keyState[3]==1){
      changeState(new PlainJumpState(player));return;
    }
    
    if(keyState[4]==1){
      changeState(new PlainPunchState(player));return;
    }
    if(keyState[5]==1){
      changeState(new PlainFlipState(player));return;
    }
    player.isGuard = true;
    //player.actNoMove();
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 3);
  }
}



class PlainSquatState extends PlainState{
  PlainSquatState(PlainPlayer player_){
    player = player_;
    no = 5;
    count = 0;
    limit = -1;
  }
  void startUp(){
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    if(commandBrunching()!=null){changeState(commandBrunching());return;}
    if(keyState[1]==0){
      if(player.keyState[0]>0 && player.keyState[2]==0){//右キー入力
        if(player.direction==-1 && player.isConfronting){changeState(new PlainGuardState(player));return;}
        else changeState(new PlainWalkState(player));
      }
      else if(player.keyState[0]==0 && player.keyState[2]>0){//左キー入力
        if(player.direction== 1 && player.isConfronting){changeState(new PlainGuardState(player));return;}
        else changeState(new PlainWalkState(player));
      }
      else {
        changeState(new PlainIdolState(player));return;
      }
    }
    if(keyState[3]==1){
      changeState(new PlainJumpState(player));return;
    }
    
    if(keyState[4]==1){
      changeState(new PlainTrippedState(player));return;
    }
    if(keyState[5]==1){
      changeState(new PlainFlipState(player));return;
    }
  }
  PImage drawSprite(PImage[] images){
    return loopAnimation(images, 3);
  }
}

class PlainJumpState extends PlainState{
  PlainJumpState(PlainPlayer player_){
    player = player_;
    no = 7;
    count = 0;
    limit=-1;
  }
  void startUp(){
    player.actJump();
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    
    if(player.isGrounding>0){
      changeState(new PlainLandState(player));return;
    }
    
    if(keyState[0]>0 && keyState[2]==0){
      player.actMoveRight();
    }
    else if(keyState[0]==00 && keyState[2]>0){
      player.actMoveLeft();
    }
    else{
        //player.actNoMove();
    }
    
    
    if(keyState[3]==1){
    }
    
    if(keyState[4]==1){
      if(commandDetection(player.command.now(), 1, 3)){//コマンド入力リストの後ろから
        changeState(new PlainWhirlwindKickState(player));return;
      }
      
      changeState(new PlainJumpKickState(player));return;
    }
    if(keyState[5]==1){
      changeState(new PlainFlipState(player));return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 3);
  }
}

class PlainLandState extends PlainState{
  PlainLandState(PlainPlayer player_){
    player = player_;
    no = 8;
    count = 0;
    limit = 3;
  }
  void startUp(){
    effectsHolder.add(new Effect(effectsHolder, effectDataArea[0],
      "DustL", new Object(null, player.x+player.wid/2, player.y+player.hig)));
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    if(count==limit){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 3);
  }
}

class PlainPunchState extends PlainState{
  PlainPunchState(PlainPlayer player_){
    player = player_;
    no = 9;
    count = 0;
    limit = 16;
  }
  void startUp(){
    player.actPunch();
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    if(count==limit){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 5);
  }
}
class PlainKickState extends PlainState{
  PlainKickState(PlainPlayer player_){
    player = player_;
    no = 10;
    count = 0;
    limit = 24;
  }
  void startUp(){
    player.actKick();
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    if(count==limit){
      defaultBrunching();return;
    }
    player.actDurKick();
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 8);
  }
}

class PlainJumpKickState extends PlainState{
  PlainState stateBuffer;
  PlainJumpKickState(PlainPlayer player_){//キャラ特有の動きを作る場合はとる引数の型を指定する
    player = player_;
    no = 14;
    count = 0;
    limit = -1;
  }
  void startUp(){
    player.actJumpKick();
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    if(player.isGrounding>0){
      changeState(new PlainLandState(player));return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 3);
  }
}
class PlainTrippedState extends PlainState{
  PlainTrippedState(PlainPlayer player_){//キャラ特有の動きを作る場合はとる引数の型を指定する
    player = player_;
    no = 11;
    count = 0;
    limit = 10;
  }
  void startUp(){
    player.actTripped();
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    if(count==limit){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 3);
  }
}

class PlainFlipState extends PlainState{
  PlainFlipState(PlainPlayer player_){
    player = player_;
    no = 13;
    count = 0;
    limit = 10;
  }
  void startUp(){
    player.actFlip();
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    if(count==limit){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 3);
  }
}

class PlainShootBulletState extends PlainState{
  PlainShootBulletState(PlainPlayer player_){
    player = player_;
    no = 16;
    count = 0;
    limit = 40;
  }
  void startUp(){
    
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    
    if(count==10)player.actShootBullet();
    
    if(count==limit){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 5);
  }
}

class PlainShootBackState extends PlainState{
  PlainShootBackState(PlainPlayer player_){
    player = player_;
    no = 12;
    count = 0;
    limit = 40;
  }
  void startUp(){
    
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    
    if(count==10)player.actShootBack();
    
    if(count==limit){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 5);
  }
}

class PlainWhirlwindKickState extends PlainState{
  PlainWhirlwindKickState(PlainPlayer player_){
    player = player_;
    count = 0;
    no = 17;
    limit = 40;
  }
  void startUp(){
    player.actWhirlwindKick();
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    
    if(count==limit||player.isGrounding>0){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    return loopAnimation(images, 2);
  }
}

class PlainGuardRigorState extends PlainState{
  PlainGuardRigorState(PlainPlayer player_){
    player = player_;
    no = 6;
    count = 0;
    limit = 20;
  }
  void startUp(){
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(count==limit){
      player.damaged = 0;
      defaultBrunching();return;
    }
    //player.actNoMove();
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 3);
  }
}

class PlainBeHitLState extends PlainState{
  PlainBeHitLState(PlainPlayer player_){
    player = player_;
    no = 2;
    count = 0;
    limit = 30;
  }
  void startUp(){
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(count==limit){
      player.damaged = 0;
      defaultBrunching();return;
    }
    //player.actNoMove();
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 3);
  }
}

class PlainBeHeldState extends PlainState{//全員いる
  PlainBeHeldState(PlainPlayer player_){
    player = player_;
    no = 2;
    count = 0;
    limit = 30;
  }
  void startUp(){
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    if(count==limit){
      player.damaged = 0;
      defaultBrunching();return;
    }
    //player.actNoMove();
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 3);
  }
}

class PlainCounterWaitState extends PlainState{
  PlainCounterWaitState(PlainPlayer player_){
    player = player_;
    no = 17;
    count = 0;
    limit = 10;
  }
  void startUp(){
    
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    
    if(count==10)player.actShootBullet();
    
    if(count==limit){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 5);
  }
}