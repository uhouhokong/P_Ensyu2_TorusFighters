//担当:大曽根
//キャラクターに関するクラス


/************状態クラスの雛形（コピペ用）***********
 class Sotai__State extends SotaiState{
 Sotai__State(SotaiPlayer player_){
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
class Sotai__State extends SotaiState {
  Sotai__State(SotaiPlayer player_) {
    player = player_;
    no = 0;//状態の通し番号
    count = 0;
    limit =-1;//状態が終了するまでの時間を指定、-1だと無限
  }
  void startUp() {
    //開始時の処理を以下のように書く
    //player.act__();
  }

  void update(int[] keyState) {
    countUp();//カウントする この処理は必ず行う
    if (damageBrunching(0))return;//ダメージ時の分岐を行うときこの行を追加しておく
    //通常は引数に0、大げさにダメージを受けたいとき1を指定、
    //また、被ダメージ状態に移行しないときこの行を削除する

    //ループ時の処理を以下のように書く
    //player.act__();

    //指定した状態に変遷する時は条件分岐＋changeState()で行う
    //changeState(new Sotai__State(player));の直後にreturn;しておくと
    //意図しない状態に変遷することがなく安全

    if (keyState[4]==1) {
      changeState(new SotaiPunchState(player));
      return;
    }

    //ループを脱するときの処理を以下のように書く
    if (count==limit) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    //いずれかの行を追加する
    return straightAnimation(images, 3);
    //return loopAnimation(images, 3);
    //return fullAnimation(images);
  }
}

//
class SotaiState extends State {
  SotaiPlayer player;
  void changeState(State nextState) {
    if (nextState==null)return;
    player.changeState(nextState);
  }
  State commandBrunching() {
    if (player.keyState[4]!=1)return null;
    Integer[] input = player.command.now();

    if (commandDetection(input, 1+player.direction, 1, 1-player.direction)) {//コマンド入力リストの後ろから
      return new SotaiShootBulletState(player);
    }
    if (commandDetection(input, 1+player.direction, 1, 1-player.direction)) {//コマンド入力リストの後ろから
      return new SotaiShootBulletState(player);
    }
    if (commandDetection(input, 1, 1, 1-player.direction)) {
      return new SotaiTatakitukeState(player);
    }
    
    return null;
  }

  void defaultBrunching() {
    if (player.stateBuffer!=null) {
      changeState(player.stateBuffer);
      player.stateBuffer=null;
      player.stateBufCount=-1;
    } else if (player.isGrounding==0) {
      changeState(new SotaiJumpState(player));
    } else if (player.keyState[0]>0 && player.keyState[2]==0) {//右キー入力
      if (player.direction==-1 && player.isConfronting)changeState(new SotaiGuardState(player));
      else changeState(new SotaiWalkState(player));
    } else if (player.keyState[0]==0 && player.keyState[2]>0) {//左キー入力
      if (player.direction== 1 && player.isConfronting)changeState(new SotaiGuardState(player));
      else changeState(new SotaiWalkState(player));
    } else if (player.keyState[1]>0) {
      changeState(new SotaiSquatState(player));
    } else if (player.keyState[3]>0) {
      changeState(new SotaiJumpState(player));
    } else if(player.sensorState==1){
      changeState(new SotaiCounterWaitState(player));
    }{
      changeState(new SotaiIdolState(player));
    }
  }
  boolean damageBrunching(int receiveType) {
    if (player.damaged==0)return false;
    if (player.isGrounding==0)receiveType++;
    println("damaged:" + (player.damaged+receiveType));
    switch(max(0, min(player.damaged+receiveType, 2))) {
    case 0:
      changeState(new SotaiGuardRigorState(player));
      return true;
    case 1:
      changeState(new SotaiBeHitLState(player));
      return true;
    case 2:
      changeState(new SotaiBeHitHState(player));
      return true;
    }
    return false;
  }
}
//通常時の挙動
class SotaiIdolState extends SotaiState {
  SotaiIdolState(SotaiPlayer player_) {
    player = player_;
    no = 3;
    count = 0;
    limit = -1;
  }

  void startUp() {
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;
    if (commandBrunching()!=null) {
      changeState(commandBrunching());
      return;
    }

    if (player.keyState[0]>0 && player.keyState[2]==0) {//右キー入力
      if (player.direction==-1 && player.isConfronting) {
        changeState(new SotaiGuardState(player));
        return;
      } else changeState(new SotaiWalkState(player));
    } else if (player.keyState[0]==0 && player.keyState[2]>0) {//左キー入力
      if (player.direction== 1 && player.isConfronting) {
        changeState(new SotaiGuardState(player));
        return;
      } else changeState(new SotaiWalkState(player));
    } else {
      //player.actNoMove();
    }

    if (keyState[1]>1) {
      changeState(new SotaiSquatState(player));
      return;
    }
    if (keyState[3]==1) {
      changeState(new SotaiJumpState(player));
      return;
    }

    if (keyState[4]==1) {
      changeState(new SotaiPunchState(player));
      return;
    }
    if (keyState[5]==1) {
      changeState(new SotaiFlipState(player));
      return;
    }
    if(player.sensorState==1){
      changeState(new SotaiCounterWaitState(player));return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return loopAnimation(images, 3);
  }
}
//歩行時の挙動
class SotaiWalkState extends SotaiState {
  SotaiWalkState(SotaiPlayer player_) {
    player = player_;
    no = 4;
    count = 0;
    limit = -1;
  }
  void startUp() {
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;
    if (commandBrunching()!=null) {
      changeState(commandBrunching());
      return;
    }
    if (keyState[0]>0 && keyState[2]==0) {
      if (player.direction==-1 && player.isConfronting) {
        changeState(new SotaiGuardState(player));
        return;
      }
      player.actMoveRight();
    } else if (keyState[0]==00 && keyState[2]>0) {
      if (player.direction== 1 && player.isConfronting) {
        changeState(new SotaiGuardState(player));
        return;
      }
      player.actMoveLeft();
    } else {
      changeState(new SotaiIdolState(player));
      return;
    }

    if (keyState[1]>1) {
      changeState(new SotaiSquatState(player));
      return;
    }
    if (keyState[3]==1) {
      changeState(new SotaiJumpState(player));
      return;
    }

    if (keyState[4]==1) {
      changeState(new SotaiKickState(player));
      return;
    }
    if (keyState[5]==1) {
      Player otherPlayer = player.stage.player[(player.no+1)%2];
      if (otherPlayer.collider.colliding(new Collider(player.stage, (Player)player, player.wid/2-10, player.hig/2-player.hig/2, 20, player.collider.hig, 1, false, false))) {
        changeState(new SotaiThrowState(player, otherPlayer));
        println("つかみ発生");
        return;
      } else {
        changeState(new SotaiFlipState(player));
        return;
      }
    }
    if(player.sensorState==1){
      changeState(new SotaiCounterWaitState(player));return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return loopAnimation(images, 6);
  }
}
//ガード時の挙動
class SotaiGuardState extends SotaiState {
  SotaiGuardState(SotaiPlayer player_) {
    player = player_;
    no = 6;
    count = 0;
    limit = -1;
  }
  void startUp() {
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(-1))return;
    player.isGuard = false;
    if (commandBrunching()!=null) {
      changeState(commandBrunching());
      return;
    }
    if (keyState[0]>0 && keyState[2]==0) {
      if (player.direction==-1 && player.isConfronting) {
      }
    } else if (keyState[0]==00 && keyState[2]>0) {
      if (player.direction== 1 && player.isConfronting) {
      }
    } else {
      changeState(new SotaiIdolState(player));
      return;
    }

    if (keyState[1]>1) {
      changeState(new SotaiSquatState(player));
      return;
    }
    if (keyState[3]==1) {
      changeState(new SotaiJumpState(player));
      return;
    }

    if (keyState[4]==1) {
      changeState(new SotaiPunchState(player));
      return;
    }
    if (keyState[5]==1) {
      changeState(new SotaiFlipState(player));
      return;
    }
    if(player.sensorState==1){
      changeState(new SotaiCounterWaitState(player));return;
    }
    player.isGuard = true;
    //player.actNoMove();
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}


//しゃがみ時の挙動
class SotaiSquatState extends SotaiState {
  SotaiSquatState(SotaiPlayer player_) {
    player = player_;
    no = 5;
    count = 0;
    limit = -1;
  }
  void startUp() {
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;
    if (commandBrunching()!=null) {
      changeState(commandBrunching());
      return;
    }
    if (keyState[1]==0) {
      if (player.keyState[0]>0 && player.keyState[2]==0) {//右キー入力
        if (player.direction==-1 && player.isConfronting) {
          changeState(new SotaiGuardState(player));
          return;
        } else changeState(new SotaiWalkState(player));
      } else if (player.keyState[0]==0 && player.keyState[2]>0) {//左キー入力
        if (player.direction== 1 && player.isConfronting) {
          changeState(new SotaiGuardState(player));
          return;
        } else changeState(new SotaiWalkState(player));
      } else {
        changeState(new SotaiIdolState(player));
        return;
      }
    }
    if (keyState[3]==1) {
      changeState(new SotaiJumpState(player));
      return;
    }

    if (keyState[4]==1) {
      changeState(new SotaiTrippedState(player));
      return;
    }
    if (keyState[5]==1) {
      changeState(new SotaiFlipState(player));
      return;
    }
    if(player.sensorState==1){
      changeState(new SotaiCounterWaitState(player));return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return loopAnimation(images, 3);
  }
}
//ジャンプ時の挙動
class SotaiJumpState extends SotaiState {
  SotaiJumpState(SotaiPlayer player_) {
    player = player_;
    no = 7;
    count = 0;
    limit=-1;
  }
  void startUp() {
    player.actJump();
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;

    if (player.isGrounding>0) {
      changeState(new SotaiLandState(player));
      return;
    }

    if (keyState[0]>0 && keyState[2]==0) {
      player.actMoveRight();
    } else if (keyState[0]==00 && keyState[2]>0) {
      player.actMoveLeft();
    } else {
      //player.actNoMove();
    }


    if (keyState[3]==1) {
    }

    if (keyState[4]==1) {
      if (commandDetection(player.command.now(), 1, 3)) {//コマンド入力リストの後ろから
        changeState(new SotaiWhirlwindKickState(player));
        return;
      }

      changeState(new SotaiJumpKickState(player));
      return;
    }
    if (keyState[5]==1) {
      changeState(new SotaiFlipState(player));
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}
//着地時の挙動
class SotaiLandState extends SotaiState {
  SotaiLandState(SotaiPlayer player_) {
    player = player_;
    no = 8;
    count = 0;
    limit = 3;
  }
  void startUp() {
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;
    if (count==limit) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}
//パンチ時の挙動
class SotaiPunchState extends SotaiState {
  SotaiPunchState(SotaiPlayer player_) {
    player = player_;
    no = 9;
    count = 0;
    limit = 16;
  }
  void startUp() {
    player.actPunch();
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;
    if (count==limit) {
      defaultBrunching();
      return;
    }
    if(commandDetection(player.command.now(), 1, 3)){//コマンド入力リストの後ろから
        changeState(new SotaiApperState(player));return;
      }
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}
//コマンド技の挙動
class SotaiTatakitukeState extends SotaiState{
  SotaiTatakitukeState(SotaiPlayer player_){
    player = player_;
    no = 20;
    count = 0;
    limit = 16;
  }
  void startUp(){
    player.actTatakituke();
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
//派生技の挙動
class SotaiApperState extends SotaiState{
  SotaiApperState(SotaiPlayer player_){
    player = player_;
    no = 21;
    count = 0;
    limit = 16;
  }
  void startUp(){
    player.actApper();
  }
  
  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    if(count==limit){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 6);
  }
}
//キック時の挙動
class SotaiKickState extends SotaiState {
  SotaiKickState(SotaiPlayer player_) {
    player = player_;
    no = 10;
    count = 0;
    limit = 24;
  }
  void startUp() {
    player.actKick();
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;
    if (count==limit) {
      defaultBrunching();
      return;
    }
    player.actDurKick();
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}
//飛び蹴り時の挙動
class SotaiJumpKickState extends SotaiState {
  SotaiState stateBuffer;
  SotaiJumpKickState(SotaiPlayer player_) {//キャラ特有の動きを作る場合はとる引数の型を指定する
    player = player_;
    no = 14;
    count = 0;
    limit = -1;
  }
  void startUp() {
    player.actJumpKick();
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;
    if (player.isGrounding>0) {
      changeState(new SotaiLandState(player));
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}
class SotaiTrippedState extends SotaiState {
  SotaiTrippedState(SotaiPlayer player_) {//キャラ特有の動きを作る場合はとる引数の型を指定する
    player = player_;
    no = 11;
    count = 0;
    limit = 10;
  }
  void startUp() {
    player.actTripped();
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;
    if (count==limit) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}
//反転時の挙動
class SotaiFlipState extends SotaiState {
  SotaiFlipState(SotaiPlayer player_) {
    player = player_;
    no = 13;
    count = 0;
    limit = 10;
  }
  void startUp() {
    player.actFlip();
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;
    if (count==limit) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}
//飛び道具使用時の挙動
class SotaiShootBulletState extends SotaiState {
  SotaiShootBulletState(SotaiPlayer player_) {
    player = player_;
    no = 16;
    count = 0;
    limit = 40;
  }
  void startUp() {
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;

    if (count==10)player.actShootBullet();

    if (count==limit) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 5);
  }
}
//回転蹴り時の挙動
class SotaiWhirlwindKickState extends SotaiState {
  SotaiWhirlwindKickState(SotaiPlayer player_) {
    player = player_;
    count = 0;
    no = 17;
    limit = 40;
  }
  void startUp() {
    player.actWhirlwindKick();
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;

    if (count==limit||player.isGrounding>0) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return loopAnimation(images, 2);
  }
}

class SotaiGuardRigorState extends SotaiState {
  SotaiGuardRigorState(SotaiPlayer player_) {
    player = player_;
    no = 6;
    count = 0;
    limit = 20;
  }
  void startUp() {
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (count==limit) {
      player.damaged = 0;
      defaultBrunching();
      return;
    }
    //player.actNoMove();
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}

class SotaiBeHitLState extends SotaiState {
  SotaiBeHitLState(SotaiPlayer player_) {
    player = player_;
    no = 2;
    count = 0;
    limit = 30;
  }
  void startUp() {
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (count==limit) {
      player.damaged = 0;
      defaultBrunching();
      return;
    }
    //player.actNoMove();
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}

class SotaiBeHitHState extends SotaiState {//全員必要
  SotaiBeHitHState(SotaiPlayer player_) {
    player = player_;
    no = 1;
    count = 0;
    limit = -1;
  }
  void startUp() {
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (player.isGrounding>0) {
      player.damaged = 0;
      changeState(new SotaiBeStruckState(player));
      return;
    }
    //player.actNoMove();
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}
class SotaiBeHeldState extends SotaiState {
  SotaiBeHeldState(SotaiPlayer player_) {
    player = player_;
    no = 2;
    count = 0;
    limit = 30;
  }
  void startUp() {
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;
    if (count==limit) {
      player.damaged = 0;
      defaultBrunching();
      return;
    }
    //player.actNoMove();
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}

class SotaiBeStruckState extends SotaiState {//全員必要
  SotaiBeStruckState(SotaiPlayer player_) {
    player = player_;
    no = 0;
    count = 0;
    limit = 5;
  }
  void startUp() {
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (count==limit) {
      defaultBrunching();
      return;
    }
    //player.actNoMove();
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}


class SotaiCounterWaitState extends SotaiState {//
  SotaiCounterWaitState(SotaiPlayer player_) {
    player = player_;
    no = 18;
    count = 0;
    limit = 20;
  }
  void startUp() {
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;

    if (count==limit) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return fullAnimation(images);
  }
}

class SotaiCounterState extends SotaiState {//全員必要
  SotaiCounterState(SotaiPlayer player_) {
    player = player_;
    no = 17;
    count = 0;
    limit = 20;
  }
  void startUp() {
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;

    if (count==limit) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 7);
  }
}
class SotaiCounterBulletState extends SotaiState {
  Bullet otherBullet;
  SotaiCounterBulletState(SotaiPlayer player_, Bullet otherBullet_) {
    player = player_;
    no = 17;
    count = 0;
    limit = 15;
    otherBullet = otherBullet_;
  }
  void startUp() {
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0))return;

    if (count==5)otherBullet.filpHlizon((Player)player);

    if (count==limit) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 5);
  }
}
//投げ技の挙動
class SotaiThrowState extends SotaiState {//全員必要
  Player otherPlayer;
  SotaiThrowState(SotaiPlayer player_, Player otherPlayer_) {
    player = player_;
    no = 19;
    count = 0;
    limit = 45;
    otherPlayer = otherPlayer_;
  }
  void startUp() {
    player.actHoldOther(otherPlayer);
  }

  void update(int[] keyState) {
    countUp();//カウントする
    if (damageBrunching(0)) {
      otherPlayer.beFree();
      return;
    }

    if (count==20) {
      player.actThrowOther(otherPlayer);
    }

    if (count==limit) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 13);
  }
}
}