class TestPlayer extends Player{
  //int [] frameList ={};
  
  TestPlayer(){
  name = "Test";
  state = new TestIdolState(this);
  loadImages();
  }
  
  void loadImages(){
    //省略
  }
  
  //振る舞いを関数として提供、act[英単語]()の形で
  
  void actPunch(){
    addCollider(direction*wid*2/3, -hig/5, wid, hig/3, -1);}
  void actKick(){
    addCollider(direction*wid*2/3, hig/5, wid*3/2, hig/3, -1);}
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
  void actWhirlwindKick(){
    vy = -VY0/3;
    addCollider(direction*wid*2/3, hig/5, wid*2/3, hig/3, -1);
    addCollider(-direction*wid*2/3, hig/5, wid*2/3, hig/3, -1);
  }
  void beHeld(){//全部に実装
    changeState(new TestBeHeldState(this));
  }
  void beFree(){//全部に実装
    changeState(new TestLandState(this));
  }
  void getDamage(Collider other){//全部に実装
    /*if(state instanceof TestCounterWaitState){
      if(other instanceof Bullet){
        changeState(new TestCounterBulletState(this,(Bullet)other));
      }
    }
    else{
      super.getDamage(other);
    }*/
    super.getDamage(other);
  }
}

/************状態クラスの雛形（コピペ用）***********
class Test__State extends TestState{
  Test__State(TestPlayer player_){
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
class Test__State extends TestState{
  Test__State(TestPlayer player_){
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
    //changeState(new Test__State(player));の直後にreturn;しておくと
    //意図しない状態に変遷することがなく安全
    
    if(keyState[4]==1){
      changeState(new TestPunchState(player));return;
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
class TestState extends State{
  TestPlayer player;
  void changeState(State nextState){
    if(nextState==null)return;
    player.changeState(nextState);
  
  }
  State commandBrunching(){
    if(player.keyState[4]!=1)return null;
    Integer[] input = player.command.now();
    
    if(commandDetection(input, 1+player.direction, 1, 1-player.direction)){//コマンド入力リストの後ろから
      return new TestShootBulletState(player);
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
      changeState(new TestJumpState(player));
    }
    else if(player.keyState[0]>0 && player.keyState[2]==0){//右キー入力
      if(player.direction==-1 && player.isConfronting)changeState(new TestGuardState(player));
      else changeState(new TestWalkState(player));
    }
    else if(player.keyState[0]==0 && player.keyState[2]>0){//左キー入力
      if(player.direction== 1 && player.isConfronting)changeState(new TestGuardState(player));
      else changeState(new TestWalkState(player));
    }
    else if(player.keyState[1]>0){
    changeState(new TestSquatState(player));
    }
    else if(player.keyState[3]>0){
    changeState(new TestJumpState(player));
    }
    else{
      changeState(new TestIdolState(player));
    }
  }
  boolean damageBrunching(int receiveType){
    if(player.damaged==0)return false;
    if(player.isGrounding==0)receiveType++;
    println("damaged:" + (player.damaged+receiveType));
    switch(max(0,min(player.damaged+receiveType,2))){
      case 0:changeState(new TestGuardRigorState(player));return true;
      case 1:changeState(new TestBeHitLState(player));return true;
      case 2:changeState(new TestBeHitLState(player));return true;
    }
    return false;
  }
}

class TestIdolState extends TestState{
  TestIdolState(TestPlayer player_){
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
      if(player.direction==-1 && player.isConfronting){changeState(new TestGuardState(player));return;}
      else changeState(new TestWalkState(player));
    }
    else if(player.keyState[0]==0 && player.keyState[2]>0){//左キー入力
      if(player.direction== 1 && player.isConfronting){changeState(new TestGuardState(player));return;}
      else changeState(new TestWalkState(player));
    }
    else{
      //player.actNoMove();
    }
    
    if(keyState[1]>1){
      changeState(new TestSquatState(player));return;
    }
    if(keyState[3]==1){
      changeState(new TestJumpState(player));return;
    }
    
    if(keyState[4]==1){
      changeState(new TestPunchState(player));return;
    }
    if(keyState[5]==1){
      changeState(new TestFlipState(player));return;
    }
  }
  PImage drawSprite(PImage[] images){
    return loopAnimation(images, 3);
  }
}

class TestWalkState extends TestState{
  TestWalkState(TestPlayer player_){
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
      if(player.direction==-1 && player.isConfronting){changeState(new TestGuardState(player));return;}
      player.actMoveRight();
    }
    else if(keyState[0]==00 && keyState[2]>0){
      if(player.direction== 1 && player.isConfronting){changeState(new TestGuardState(player));return;}
      player.actMoveLeft();
    }
    
    else {
      changeState(new TestIdolState(player));return;}
    
    if(keyState[1]>1){
      changeState(new TestSquatState(player));return;
    }
    if(keyState[3]==1){
      changeState(new TestJumpState(player));return;
    }
    
    if(keyState[4]==1){
      changeState(new TestKickState(player));return;
    }
    if(keyState[5]==1){
      changeState(new TestFlipState(player));return;
    }
  }
  PImage drawSprite(PImage[] images){
    return loopAnimation(images, 3);
  }
}

class TestGuardState extends TestState{
  TestGuardState(TestPlayer player_){
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
      changeState(new TestIdolState(player));return;}
    
    if(keyState[1]>1){
      changeState(new TestSquatState(player));return;
    }
    if(keyState[3]==1){
      changeState(new TestJumpState(player));return;
    }
    
    if(keyState[4]==1){
      changeState(new TestPunchState(player));return;
    }
    if(keyState[5]==1){
      changeState(new TestFlipState(player));return;
    }
    player.isGuard = true;
    //player.actNoMove();
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 3);
  }
}



class TestSquatState extends TestState{
  TestSquatState(TestPlayer player_){
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
        if(player.direction==-1 && player.isConfronting){changeState(new TestGuardState(player));return;}
        else changeState(new TestWalkState(player));
      }
      else if(player.keyState[0]==0 && player.keyState[2]>0){//左キー入力
        if(player.direction== 1 && player.isConfronting){changeState(new TestGuardState(player));return;}
        else changeState(new TestWalkState(player));
      }
      else {
        changeState(new TestIdolState(player));return;
      }
    }
    if(keyState[3]==1){
      changeState(new TestJumpState(player));return;
    }
    
    if(keyState[4]==1){
      changeState(new TestTrippedState(player));return;
    }
    if(keyState[5]==1){
      changeState(new TestFlipState(player));return;
    }
  }
  PImage drawSprite(PImage[] images){
    return loopAnimation(images, 3);
  }
}

class TestJumpState extends TestState{
  TestJumpState(TestPlayer player_){
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
      changeState(new TestLandState(player));return;
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
        changeState(new TestWhirlwindKickState(player));return;
      }
      
      changeState(new TestJumpKickState(player));return;
    }
    if(keyState[5]==1){
      changeState(new TestFlipState(player));return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 3);
  }
}

class TestLandState extends TestState{
  TestLandState(TestPlayer player_){
    player = player_;
    no = 8;
    count = 0;
    limit = 3;
  }
  void startUp(){
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

class TestPunchState extends TestState{
  TestPunchState(TestPlayer player_){
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
    return straightAnimation(images, 3);
  }
}
class TestKickState extends TestState{
  TestKickState(TestPlayer player_){
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
    return straightAnimation(images, 3);
  }
}

class TestJumpKickState extends TestState{
  TestState stateBuffer;
  TestJumpKickState(TestPlayer player_){//キャラ特有の動きを作る場合はとる引数の型を指定する
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
      changeState(new TestLandState(player));return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 3);
  }
}
class TestTrippedState extends TestState{
  TestTrippedState(TestPlayer player_){//キャラ特有の動きを作る場合はとる引数の型を指定する
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

class TestFlipState extends TestState{
  TestFlipState(TestPlayer player_){
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

class TestShootBulletState extends TestState{
  TestShootBulletState(TestPlayer player_){
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

class TestWhirlwindKickState extends TestState{
  TestWhirlwindKickState(TestPlayer player_){
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

class TestGuardRigorState extends TestState{
  TestGuardRigorState(TestPlayer player_){
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

class TestBeHitLState extends TestState{
  TestBeHitLState(TestPlayer player_){
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

class TestBeHeldState extends TestState{
  TestBeHeldState(TestPlayer player_){
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