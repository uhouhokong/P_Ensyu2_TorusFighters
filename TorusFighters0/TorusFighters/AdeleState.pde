//担当:鈴木
//Adeleキャラクターの動き、画像指定、操作方法

/************状態クラスの雛形（参考用）***********
 class Adele__State extends AdeleState {
 Adele__State( AdelePlayer player_ ) {
 player = player_;
 no = 0;
 count = 0;
 limit =-1;
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
class Adele__State extends AdeleState {
  Adele__State(AdelePlayer player_) {
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
    //changeState(new Adele__State(player));の直後にreturn;しておくと
    //意図しない状態に変遷することがなく安全

    if (keyState[4]==1) {
      changeState(new AdelePunchState(player));
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
class AdeleState extends State {
  AdelePlayer player;
  void changeState( State nextState ) {
    if ( nextState == null ) {
      return;
    }
    player.changeState( nextState );
  }
  State commandBrunching() {                
    if ( player.keyState[4] != 1) { 
      return null;
    }
    Integer [] input = player.command.now();

    if ( commandDetection( input, 1+player.direction, 1, 1-player.direction )) {      //コマンド技操作方法
      return new AdeleShootBulletState( player );
    }    

    if ( commandDetection( input, 1-player.direction, 1, 1+player.direction )) {      //コマンド技操作方法２
      return new AdeleShootBulletState2 ( player );
    }

    return null;
  }

  void defaultBrunching() {
    if ( player.stateBuffer != null ) {
      changeState( player.stateBuffer );
      player.stateBuffer = null;
      player.stateBufCount = -1;
    } else if ( player.isGrounding == 0 ) {
      changeState( new AdeleJumpState( player ));
    } else if ( player.keyState[0] > 0 && player.keyState[2] == 0 ) {//右キー入力
      if ( player.direction == -1 && player.isConfronting )  changeState(new AdeleGuardState( player ));
      else changeState( new AdeleWalkState( player ));
    } else if ( player.keyState[0] == 0 && player.keyState[2] > 0 ) {//左キー入力
      if ( player.direction == 1 && player.isConfronting )  changeState( new AdeleGuardState( player ));
      else changeState( new AdeleWalkState( player ));
    } else if ( player.keyState[1] > 0 ) {
      changeState( new AdeleSquatState( player ));
    } else if ( player.keyState[3] > 0 ) {
      changeState( new AdeleJumpState( player ));
    } else {
      changeState( new AdeleIdolState( player ));
    }
  }
  boolean damageBrunching ( int receiveType ) {
    if ( player.damaged == 0 )  return false;
    if ( player.isGrounding == 0 )  receiveType++;
    println( "damaged:" + ( player.damaged + receiveType ));
    switch( max (0, min( player.damaged+receiveType, 2 ))) {
    case 0:
      changeState( new AdeleGuardRigorState( player ));
      return true;
    case 1:
      changeState( new AdeleBeHitLState( player ));
      return true;
    case 2:
      changeState( new AdeleBeHitLState( player ));
      return true;
    }
    return false;
  }
}

class AdeleIdolState extends AdeleState {       //待機クラス
  AdeleIdolState( AdelePlayer player_ ) {
    player = player_;
    no = 2;
    count = 0;
    limit = -1;
  }

  void startUp() {
  }

  void update( int[] keyState ) {
    countUp();
    if ( damageBrunching(0) ) return;
    if ( commandBrunching() != null ) {
      changeState ( commandBrunching() );
      return;
    }

    if ( player.keyState[0] > 0 && player.keyState[2] == 0 ) {//右キー入力
      if ( player.direction == -1 && player.isConfronting ) {
        changeState( new AdeleGuardState( player ));
        return;
      } else changeState( new AdeleWalkState( player ));
    } else if ( player.keyState[0] == 0 && player.keyState[2] > 0 ) {//左キー入力
      if ( player.direction == 1 && player.isConfronting ) {
        changeState( new AdeleGuardState( player ));
        return;
      } else changeState( new AdeleWalkState( player ));
    } else {
    }

    if ( keyState[1] > 1 ) {
      changeState( new AdeleSquatState( player ));
      return;
    }
    if ( keyState[3] == 1 ) {
      changeState( new AdeleJumpState( player ));
      return;
    }

    if (keyState[4]==1) {
      changeState(new AdelePunchState(player));
      return;
    }
    if ( keyState[5] == 1 ) {
      changeState( new AdeleFlipState( player ));
      return;
    }
  }
  PImage drawSprite( PImage[] images ) {
    return loopAnimation( images, 3 );
  }
}

class AdeleWalkState extends AdeleState {      //歩きクラス
  AdeleWalkState( AdelePlayer player_ ) {
    player = player_;
    no = 3;
    count = 0;
    limit = -1;
  }
  void startUp() {
  }

  void update( int[] keyState ) {
    countUp();
    if ( damageBrunching(0) )  return;
    if ( commandBrunching() != null ) {
      changeState( commandBrunching() );
      return;
    }
    if ( keyState[0] > 0 && keyState[2] == 0 ) {
      if ( player.direction == -1 && player.isConfronting ) {
        changeState( new AdeleGuardState( player ));
        return;
      }
      player.actMoveRight();
    } else if ( keyState[0] == 00 && keyState[2] > 0 ) {
      if ( player.direction == 1 && player.isConfronting ) {
        changeState( new AdeleGuardState( player ));
        return;
      }
      player.actMoveLeft();
    } else {
      changeState( new AdeleIdolState( player ));
      return;
    }

    if ( keyState[1] > 1) {
      changeState( new AdeleSquatState( player ));
      return;
    }
    if ( keyState[3] == 1 ) {
      changeState( new AdeleJumpState( player ));
      return;
    }

    if ( keyState[4] == 1 ) {      //zkey
      changeState( new AdeleKickState( player ));
      return;
    }
    if ( keyState[5] == 1 ) {      //xkey
      Player otherPlayer = player.stage.player[ ( player.no+1 ) % 2 ];
      if ( otherPlayer.collider.colliding( new Collider( player.stage, ( Player )player, player.wid/2-10, player.hig/2-player.hig/2, 20, player.collider.hig, 1, false, false ))) {
        changeState( new AdeleThrowState( player, otherPlayer ));
        println( "つかみ発生" );
        return;
      } else {
        changeState( new AdeleFlipState( player ));
        return;
      }
    }
  }
  PImage drawSprite( PImage[] images ) {
    return loopAnimation( images, 3 );
  }
}

class AdeleGuardState extends AdeleState {     //守りクラス
  AdeleGuardState( AdelePlayer player_ ) {
    player = player_;
    no = 4;
    count = 0;
    limit = -1;
  }
  void startUp() {
  }

  void update( int[] keyState ) {
    countUp();
    if ( damageBrunching( -1 ))  return;
    player.isGuard = false;
    if ( commandBrunching() != null ) {
      changeState( commandBrunching() );
      return;
    }
    if ( keyState[0] > 0 && keyState[2] == 0 ) {
      if ( player.direction == -1 && player.isConfronting ) {
      }
    } else if ( keyState[0] == 00 && keyState[2] > 0 ) {
      if ( player.direction == 1 && player.isConfronting ) {
      }
    } else {
      changeState( new AdeleIdolState( player ));
      return;
    }

    if (keyState[1] > 1) {
      changeState( new AdeleSquatState( player ));
      return;
    }
    if (keyState[3] == 1 ) {
      changeState( new AdeleJumpState( player ));
      return;
    }

    if (keyState[4] == 1 ) {
      changeState( new AdelePunchState( player ));
      return;
    }
    if (keyState[5] == 1 ) {
      changeState( new AdeleFlipState( player ));
      return;
    }
    player.isGuard = true;
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 3 );
  }
}



class AdeleSquatState extends AdeleState {      //しゃがむクラス
  AdeleSquatState( AdelePlayer player_ ) {
    player = player_;
    no = 5;
    count = 0;
    limit = -1;
  }
  void startUp() {
  }

  void update( int[] keyState ) {
    countUp();
    if ( damageBrunching( 0 ))  return;
    if ( commandBrunching() != null ) {
      changeState( commandBrunching() );
      return;
    }
    if ( keyState[1] == 0 ) {
      if ( player.keyState[0] > 0 && player.keyState[2] == 0 ) {//右キー入力
        if ( player.direction == -1 && player.isConfronting ) {
          changeState( new AdeleGuardState( player ));
          return;
        } else changeState( new AdeleWalkState( player ));
      } else if ( player.keyState[0] == 0 && player.keyState[2] > 0 ) {//左キー入力
        if ( player.direction == 1 && player.isConfronting ) {
          changeState( new AdeleGuardState( player ));
          return;
        } else changeState( new AdeleWalkState( player ));
      } else {
        changeState( new AdeleIdolState( player ));
        return;
      }
    }
    if ( keyState[3] == 1 ) {
      changeState( new AdeleJumpState( player ));
      return;
    }

    if ( keyState[5] == 1 ) {
      changeState( new AdeleFlipState( player ));
      return;
    }
  }
  PImage drawSprite( PImage [] images ) {
    return loopAnimation( images, 3 );
  }
}

class AdeleJumpState extends AdeleState {      //ジャンプクラス
  AdeleJumpState( AdelePlayer player_ ) {
    player = player_;
    no = 6;
    count = 0;
    limit=-1;
  }
  void startUp() {
    player.actJump();
  }

  void update( int [] keyState ) {      //ジャンプ中の条件分岐
    countUp();
    if ( damageBrunching( 0 ))  return;

    if ( player.isGrounding > 0 ) {
      changeState( new AdeleLandState( player ));
      return;
    }

    if (keyState[0] > 0 && keyState[2] == 0 ) {
      player.actMoveRight();
    } else if ( keyState[0] == 00 && keyState[2] > 0 ) {
      player.actMoveLeft();
    } 

    if ( keyState[3] == 1 ) {
    }

    if ( keyState[4] == 1 ) {
      changeState( new AdeleJumpKickState( player ));
      return;
    }
    if ( keyState[5] == 1 ) {
      changeState( new AdeleFlipState( player ));
      return;
    }
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 3 );
  }
}

class AdeleLandState extends AdeleState {      //ジャンプ後の着地クラス
  AdeleLandState( AdelePlayer player_ ) {
    player = player_;
    no = 7;
    count = 0;
    limit = 3;
  }
  void startUp() {
  }

  void update( int[] keyState ) {
    countUp();
    if ( damageBrunching( 0 ))  return;
    if ( count == limit ) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 3 );
  }
}

class AdelePunchState extends AdeleState {      //ハンマーで殴るクラス
  AdelePunchState( AdelePlayer player_ ) {
    player = player_;
    no = 8;
    count = 0;
    limit = 16;
  }
  void startUp() {
    player.actPunch();
  }

  void update( int[] keyState ) {
    countUp();
    if ( damageBrunching( 0 ))return;
    if ( count == limit ) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 3 );
  }
}

class AdeleKickState extends AdeleState {      //キッククラス
  AdeleKickState( AdelePlayer player_ ) {
    player = player_;
    no = 9;
    count = 0;
    limit = 24;
  }
  void startUp() {
    player.actKick();
  }

  void update( int [] keyState ) {
    countUp();
    if ( damageBrunching( 0 ))  return;
    if ( count == limit ) {
      defaultBrunching();
      return;
    }
    player.actDurKick();
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 3 );
  }
}

class AdeleJumpKickState extends AdeleState {      //ジャンプキッククラス
  AdeleState stateBuffer;      //キャラ特有の動きを作る場合はとる引数の型を指定する
  AdeleJumpKickState( AdelePlayer player_ ) {
    player = player_;
    no = 10;
    count = 0;
    limit = -1;
  }
  void startUp() {
    player.actJumpKick();
  }

  void update( int [] keyState ) {
    countUp();
    if ( damageBrunching( 0 ))  return;
    if ( player.isGrounding > 0 ) {
      changeState( new AdeleLandState( player ));
      return;
    }
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 3 );
  }
}


class AdeleFlipState extends AdeleState {       //方向転換クラス
  AdeleFlipState( AdelePlayer player_ ) {
    player = player_;
    no = 11;
    count = 0;
    limit = 10;
  }
  void startUp() {
    player.actFlip();
  }

  void update( int [] keyState ) {
    countUp();
    if ( damageBrunching( 0 ))  return;
    if ( count == limit ) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 3 );
  }
}

class AdeleShootBulletState extends AdeleState {      //コマンド技クラス
  AdeleShootBulletState( AdelePlayer player_ ) {
    player = player_;
    no = 15;
    count = 0;
    limit = 40;
  }
  void startUp() {
  }

  void update( int [] keyState ) {
    countUp();
    if ( damageBrunching( 0 ))  return;

    if ( count == 10 )  player.actShootBullet();

    if ( count == limit ) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 3 );
  }
}

class AdeleShootBulletState2 extends AdeleState {      //コマンド技２クラス
  AdeleShootBulletState2( AdelePlayer player_ ) {
    player = player_;
    no = 15;
    count = 0;
    limit = 40;
  }
  void startUp() {
    player.actShootBullet2();
  }

  void update( int [] keyState ) {
    countUp();
    if ( damageBrunching( 0 ))  return;

    if ( count == 10 ) player.actShootBullet();

    if ( count == limit ) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 3 );
  }
}

class AdeleGuardRigorState extends AdeleState {      //ガードクラス
  AdeleGuardRigorState( AdelePlayer player_ ) {
    player = player_;
    no = 4;
    count = 0;
    limit = 20;
  }
  void startUp() {
  }

  void update( int [] keyState ) {
    countUp();
    if ( count == limit ) {
      player.damaged = 0;
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 3 );
  }
}

class AdeleBeHitLState extends AdeleState {      //ダメージ大クラス
  AdeleBeHitLState( AdelePlayer player_ ) {
    player = player_;
    no = 12;
    count = 0;
    limit = 30;
  }
  void startUp() {
  }

  void update( int [] keyState ) {
    countUp();
    if ( count == limit ) {
      player.damaged = 0;
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite( PImage[] images ) {
    return straightAnimation( images, 3 );
  }
}

class Adelecommand extends AdeleState {      //コマンドクラス
  Adelecommand ( AdelePlayer player_ ) {
    player = player_;
    no = 15;
    count = 0;
    limit = -1;
  }
  void startUp () {
  }

  void update ( int [] keyState ) {
    countUp();
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 3 );
  }
}

class AdeleBeHeldState extends AdeleState {      //相手に持たれるクラス
  AdeleBeHeldState( AdelePlayer player_ ) {
    player = player_;
    no = 2;
    count = 0;
    limit = 30;
  }
  void startUp() {
  }

  void update( int [] keyState ) {
    countUp();
    if ( damageBrunching( 0 ))  return;
    if ( count == limit ) {
      player.damaged = 0;
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 3 );
  }
}

class AdeleBeStruckState extends AdeleState {      //相手に打たれるクラス
  AdeleBeStruckState( AdelePlayer player_ ) {
    player = player_;
    no = 2;
    count = 0;
    limit = 5;
  }
  void startUp() {
  }

  void update( int [] keyState ) {
    countUp();
    if ( count == limit ) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 3 );
  }
}


class AdeleCounterWaitState extends AdeleState {      //カウンター待機クラス 
  AdeleCounterWaitState( AdelePlayer player_ ) {
    player = player_;
    no = 2;
    count = 0;
    limit = 10;
  }
  void startUp() {
  }

  void update( int [] keyState ) {
    countUp();
    if ( damageBrunching( 0 ))  return;

    if ( count == limit ) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite( PImage [] images ) {
    return fullAnimation( images );
  }
}

class AdeleCounterState extends AdeleState {      //カウンタークラス
  AdeleCounterState( AdelePlayer player_ ) {
    player = player_;
    no = 2;
    count = 0;
    limit = 20;
  }
  void startUp() {
  }

  void update( int [] keyState ) {
    countUp();
    if ( damageBrunching( 0 ))  return;

    if ( count == limit ) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 7 );
  }
}

class AdeleCounterBulletState extends AdeleState {      //カウンター攻撃クラス
  Bullet otherBullet;
  AdeleCounterBulletState( AdelePlayer player_, Bullet otherBullet_ ) {
    player = player_;
    no = 2;
    count = 0;
    limit = 15;
    otherBullet = otherBullet_;
  }
  void startUp() {
  }

  void update( int [] keyState ) {
    countUp();
    if ( damageBrunching( 0 ))  return;

    if ( count == 5 )  otherBullet.filpHlizon(( Player ) player );

    if ( count == limit ) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 5 );
  }
}

class AdeleThrowState extends AdeleState {      //投げ技クラス
  Player otherPlayer;
  AdeleThrowState( AdelePlayer player_, Player otherPlayer_ ) {
    player = player_;
    no = 13;
    count = 0;
    limit = 45;
    otherPlayer = otherPlayer_;
  }
  void startUp() {
    player.actHoldOther( otherPlayer );
  }

  void update( int [] keyState ) {
    countUp();
    if ( damageBrunching( 0 )) {
      otherPlayer.beFree();
      return;
    }

    if ( count == 20 ) {
      player.actThrowOther( otherPlayer );
    }

    if ( count == limit ) {
      defaultBrunching();
      return;
    }
  }
  PImage drawSprite( PImage [] images ) {
    return straightAnimation( images, 13 );
  }
}