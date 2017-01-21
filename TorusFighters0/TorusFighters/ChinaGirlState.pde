//担当:下川

/************状態クラスの雛形（参考用）***********
 class ChinaGirl__State extends ChinaGirlState{
 ChinaGirl__State(ChinaGirlPlayer player_){
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
class ChinaGirl__State extends ChinaGirlState {
  ChinaGirl__State(ChinaGirlPlayer player_) {
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
    //changeState(new ChinaGirl__State(player));の直後にreturn;しておくと
    //意図しない状態に変遷することがなく安全

    if (keyState[4]==1) {
      changeState(new ChinaGirlPunchState(player));
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


class ChinaGirlState extends State {
  ChinaGirlPlayer player;
  void changeState(State nextState) {
    if (nextState==null)return;
    player.changeState(nextState);
  }
  State commandBrunching() {
    if (player.keyState[4]!=1)return null;
    Integer[] input = player.command.now();

    if (commandDetection(input, 1+player.direction, 1, 1-player.direction)) {//コマンド入力リストの後ろから
      return new ChinaGirlShootBulletState(player);
    }
    if (commandDetection(input, 1, 1)) {//下、下、ｚキー
      return new ChinaGirlAttackState(player);
    }
    if (commandDetection(input, 1-player.direction, 1+player.direction)) {//キャラの前方、後方、ｚキー
      return new ChinaGirlEasyCombo1State(player);
    }

    return null;
  }

  void defaultBrunching() {//キー入力
    if (player.stateBuffer!=null) {
      changeState(player.stateBuffer);
      player.stateBuffer=null;
      player.stateBufCount=-1;
    } else if (player.isGrounding==0) {
      changeState(new ChinaGirlJumpState(player));
    } else if (player.keyState[0]>0 && player.keyState[2]==0) {//右キー入力
      if (player.direction==-1 && player.isConfronting)changeState(new ChinaGirlGuardState(player));
      else changeState(new ChinaGirlWalkState(player));
    } else if (player.keyState[0]==0 && player.keyState[2]>0) {//左キー入力
      if (player.direction== 1 && player.isConfronting)changeState(new ChinaGirlGuardState(player));
      else changeState(new ChinaGirlWalkState(player));
    } else if (player.keyState[1]>0) {
      changeState(new ChinaGirlSquatState(player));
    } else if (player.keyState[3]>0) {
      changeState(new ChinaGirlJumpState(player));
    } else {
      changeState(new ChinaGirlIdolState(player));
    }
  }
  boolean damageBrunching(int receiveType) {
    if (player.damaged==0)return false;
    if (player.isGrounding==0)receiveType++;
    println("damaged:" + (player.damaged+receiveType));
    switch(max(0, min(player.damaged+receiveType, 2))) {
    case 0:
      changeState(new ChinaGirlGuardRigorState(player));
      return true;
    case 1:
      changeState(new ChinaGirlBeHitLState(player));
      return true;
    case 2:
      changeState(new ChinaGirlBeHitLState(player));
      return true;
    }
    return false;
  }
}

class ChinaGirlIdolState extends ChinaGirlState {//待機
  ChinaGirlIdolState(ChinaGirlPlayer player_) {
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
        changeState(new ChinaGirlGuardState(player));
        return;
      } else changeState(new ChinaGirlWalkState(player));
    } else if (player.keyState[0]==0 && player.keyState[2]>0) {//左キー入力
      if (player.direction== 1 && player.isConfronting) {
        changeState(new ChinaGirlGuardState(player));
        return;
      } else changeState(new ChinaGirlWalkState(player));
    } else {
      //player.actNoMove();
    }

    if (keyState[1]>1) {
      changeState(new ChinaGirlSquatState(player));
      return;
    }
    if (keyState[3]==1) {
      changeState(new ChinaGirlJumpState(player));
      return;
    }

    if (keyState[4]==1) {
      changeState(new ChinaGirlPunchState(player));
      return;
    }
    if (keyState[5]==1) {
      changeState(new ChinaGirlFlipState(player));
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return loopAnimation(images, 3);
  }
}

class ChinaGirlWalkState extends ChinaGirlState {//歩き
  ChinaGirlWalkState(ChinaGirlPlayer player_) {
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
        changeState(new ChinaGirlGuardState(player));
        return;
      }
      player.actMoveRight();
    } else if (keyState[0]==00 && keyState[2]>0) {
      if (player.direction== 1 && player.isConfronting) {
        changeState(new ChinaGirlGuardState(player));
        return;
      }
      player.actMoveLeft();
    } else {
      changeState(new ChinaGirlIdolState(player));
      return;
    }

    if (keyState[1]>1) {
      changeState(new ChinaGirlSquatState(player));
      return;
    }
    if (keyState[3]==1) {
      changeState(new ChinaGirlJumpState(player));
      return;
    }

    if (keyState[4]==1) {
      changeState(new ChinaGirlKickState(player));
      return;
    }
    if (keyState[5]==1) {
      Player otherPlayer = player.stage.player[(player.no+1)%2];
      if (otherPlayer.collider.colliding(new Collider(player.stage, (Player)player, player.wid/2-10, player.hig/2-player.hig/2, 20, player.collider.hig, 1, false, false))) {
        changeState(new ChinaGirlThrowState(player, otherPlayer));
        println("つかみ発生");
        return;
      } else {
        changeState(new ChinaGirlFlipState(player));
        return;
      }
    }
  }
  PImage drawSprite(PImage[] images) {
    return loopAnimation(images, 3);
  }
}

class ChinaGirlGuardState extends ChinaGirlState {//ガード
  ChinaGirlGuardState(ChinaGirlPlayer player_) {
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
      changeState(new ChinaGirlIdolState(player));
      return;
    }

    if (keyState[1]>1) {
      changeState(new ChinaGirlSquatState(player));
      return;
    }
    if (keyState[3]==1) {
      changeState(new ChinaGirlJumpState(player));
      return;
    }

    if (keyState[4]==1) {
      changeState(new ChinaGirlPunchState(player));
      return;
    }
    if (keyState[5]==1) {
      changeState(new ChinaGirlFlipState(player));
      return;
    }
    player.isGuard = true;
    //player.actNoMove();
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}



class ChinaGirlSquatState extends ChinaGirlState {//しゃがみ
  ChinaGirlSquatState(ChinaGirlPlayer player_) {
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
          changeState(new ChinaGirlGuardState(player));
          return;
        } else changeState(new ChinaGirlWalkState(player));
      } else if (player.keyState[0]==0 && player.keyState[2]>0) {//左キー入力
        if (player.direction== 1 && player.isConfronting) {
          changeState(new ChinaGirlGuardState(player));
          return;
        } else changeState(new ChinaGirlWalkState(player));
      } else {
        changeState(new ChinaGirlIdolState(player));
        return;
      }
    }
    if (keyState[3]==1) {
      changeState(new ChinaGirlJumpState(player));
      return;
    }

    if (keyState[4]==1) {
      changeState(new ChinaGirlTrippedState(player));
      return;
    }
    if (keyState[5]==1) {
      changeState(new ChinaGirlFlipState(player));
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return loopAnimation(images, 3);
  }
}

class ChinaGirlJumpState extends ChinaGirlState {//ジャンプ
  ChinaGirlJumpState(ChinaGirlPlayer player_) {
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
      changeState(new ChinaGirlLandState(player));
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
      changeState(new ChinaGirlJumpKickState(player));
    return;
    }
    
    if (keyState[5]==1) {
      changeState(new ChinaGirlFlipState(player));
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}

class ChinaGirlLandState extends ChinaGirlState {//着地
  ChinaGirlLandState(ChinaGirlPlayer player_) {
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

class ChinaGirlPunchState extends ChinaGirlState {//パンチ
  ChinaGirlPunchState(ChinaGirlPlayer player_) {
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
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}

class ChinaGirlKickState extends ChinaGirlState {//キック
  ChinaGirlKickState(ChinaGirlPlayer player_) {
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

class ChinaGirlJumpKickState extends ChinaGirlState {//ジャンプキック
  ChinaGirlState stateBuffer;
  ChinaGirlJumpKickState(ChinaGirlPlayer player_) {//キャラ特有の動きを作る場合はとる引数の型を指定する
    player = player_;
    no = 13;
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
      changeState(new ChinaGirlLandState(player));
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}
class ChinaGirlTrippedState extends ChinaGirlState {//しゃがんで蹴る
  ChinaGirlTrippedState(ChinaGirlPlayer player_) {//キャラ特有の動きを作る場合はとる引数の型を指定する
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

class ChinaGirlFlipState extends ChinaGirlState {//方向転換
  ChinaGirlFlipState(ChinaGirlPlayer player_) {
    player = player_;
    no = 12;
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

class ChinaGirlShootBulletState extends ChinaGirlState {//飛び道具
  ChinaGirlShootBulletState(ChinaGirlPlayer player_) {
    player = player_;
    no = 14;
    count = 0;
    limit = 60;
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

class ChinaGirlGuardRigorState extends ChinaGirlState {//ガード硬直
  ChinaGirlGuardRigorState(ChinaGirlPlayer player_) {
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

class ChinaGirlBeHitLState extends ChinaGirlState {//被ダメージ
  ChinaGirlBeHitLState(ChinaGirlPlayer player_) {
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

class ChinaGirlAttackState extends ChinaGirlState {//コマンド技
  ChinaGirlAttackState(ChinaGirlPlayer player_) {
    player = player_;
    no = 15;
    count = 0;
    limit = 20;
  }
  void startUp() {
    player.actDushPunch();
  }

  void update(int[] keyState) {
    countUp();
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

class ChinaGirlEasyCombo1State extends ChinaGirlState {//コマンド技
  ChinaGirlEasyCombo1State(ChinaGirlPlayer player_) {
    player = player_;
    no = 9;
    count = 0;
    limit = -1;
  }
  void startUp() {
    player.actPunch();
  }

  void update(int[] keyState) {
    countUp();
    if (damageBrunching(0))return;
    if (player.isGrounding>0) {
      delay(100);
      changeState(new ChinaGirlEasyCombo2State(player));
      return;
    }

    if (count==limit) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}

class ChinaGirlEasyCombo2State extends ChinaGirlState {//コマンド技
  ChinaGirlEasyCombo2State(ChinaGirlPlayer player_) {
    player = player_;
    no = 10;
    count = 0;
    limit = -1;
  }
  void startUp() {
    player.actKick();
  }

  void update(int[] keyState) {
    countUp();
    if (damageBrunching(0))return;
    if (player.isGrounding>0) {
      delay(100);
      changeState(new ChinaGirlTrippedState(player));
      return;
    }

    if (count==limit) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite(PImage[] images) {
    return straightAnimation(images, 3);
  }
}


class ChinaGirlBeHeldState extends ChinaGirlState {//つかまれた時
  ChinaGirlBeHeldState(ChinaGirlPlayer player_) {
    player = player_;
    no = 12;
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

class ChinaGirlBeStruckState extends ChinaGirlState {//被ダメージ
  ChinaGirlBeStruckState(ChinaGirlPlayer player_) {
    player = player_;
    no = 1;
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


class ChinaGirlCounterWaitState extends ChinaGirlState {
  ChinaGirlCounterWaitState(ChinaGirlPlayer player_) {//カウンター待機
    player = player_;
    no = 6;
    count = 0;
    limit = 10;
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

class ChinaGirlCounterState extends ChinaGirlState {//カウンター
  ChinaGirlCounterState(ChinaGirlPlayer player_) {
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

class ChinaGirlCounterBulletState extends ChinaGirlState {//飛び道具を跳ね返す
  Bullet otherBullet;
  ChinaGirlCounterBulletState(ChinaGirlPlayer player_, Bullet otherBullet_) {
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

class ChinaGirlThrowState extends ChinaGirlState {//つかみ、投げ
  Player otherPlayer;
  ChinaGirlThrowState(ChinaGirlPlayer player_, Player otherPlayer_) {
    player = player_;
    no = 16;
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