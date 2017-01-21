//キャラクターLisaのPlayer,state,以下状態について実装
//担当:森口

class LisaPlayer extends Player{
  int [] frameList ={3,1,3,6,10,4,3,3,4,4,7,4,7,3,2,1,4,2,4,7};

  LisaPlayer(){
    name = "Lisa";
    state = new LisaIdolState(this);
    loadImages();
  }

  //frameListに応じていい感じに画像を読み込む。
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
      images[0][i][j] = loadImage("../../image/Lisa/test/"+ NumtoString(3, cnt) + ".png");//右向き画像
      images[1][i][j] = loadImage("../../image/Lisa/test_/"+ NumtoString(3, cnt) + ".png");//左向き画像
      cnt++;
      }
    }
  }

  //振る舞いを関数として提供、act[英単語]()の形で
  //対応する状態から呼び出しやすいように、管理しやすいようにしておく
  void actPunch(){
    addCollider(direction*wid*2/3, -hig/5, wid/2, hig/3, -1);}
  void actKick(){
    addCollider(direction*wid*2/3, -hig/5, wid*3/4, hig/3, 10);}
  void actDurKick(){
    vx=0;}
  void actFlip(){
    direction=-direction;
    addCollider(direction*(wid/2), 0, wid/2, hig, -1);}
  void actJumpKick(){
    addCollider(direction*wid*3/6, hig*3/10, wid*3/4, hig/2, -1);}
  void actTripped(){
    addCollider(direction*wid*2/3, hig*2/5, wid*3/4, hig/2, -1);}
  void actShootBullet(){
    Bullet newBullet = addBullet(direction*wid*2/3, 0, wid*2/3, hig/3, 140, direction*1.8, 0);
    Effect newEffect = new Effect(effectsHolder, effectDataArea[0],
      "RedBullet",new BulletEndlessLoopEffect(newBullet, newBullet.countLimit) , new Object(newBullet, newBullet.wid/2, newBullet.hig/2));
    newBullet.effect = newEffect;
    effectsHolder.add(newEffect);
  }
  void actShootBack(){
    Bullet newBullet = addBullet(-direction, -direction*wid*2/3, 0, wid*2/3, hig/3, 140, -direction*2.2, 0);
    Effect newEffect = new Effect(effectsHolder, effectDataArea[0],
      "RedBullet",new BulletEndlessLoopEffect(newBullet, newBullet.countLimit) , new Object(newBullet, newBullet.wid/2, newBullet.hig/2));
    newBullet.effect = newEffect;
    effectsHolder.add(newEffect);
  }
  void actWhirlwindKick(){
    vy = -VY0/3;
    addCollider(direction*wid*2/3, hig/5, wid*2/3, hig/3, -1);
    addCollider(-direction*wid*2/3, hig/5, wid*2/3, hig/3, -1);
  }
  void beHeld(){//全部に実装
    changeState(new LisaBeHeldState(this));
  }
  void beFree(){//全部に実装
    changeState(new LisaLandState(this));
  }
  void getDamage(Collider other){//全部に実装
    if(state instanceof LisaCounterWaitState){
      if(other instanceof Bullet){
        changeState(new LisaCounterBulletState(this,(Bullet)other));
      }
    }
    else{
      super.getDamage(other);
    }
  }

}

/************状態クラスの雛形（コピペ用）************/
//***********状態クラスの説明***********
//意味のないクラス
class Lisa__State extends LisaState{
  Lisa__State(LisaPlayer player_){
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
    //changeState(new Lisa__State(player));の直後にreturn;しておくと
    //意図しない状態に変遷することがなく安全

    if(keyState[4]==1){
      changeState(new LisaPunchState(player));return;
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

//Stateパターン。Lisaの状態ごとの処理をここに記録しておく。
class LisaState extends State{
  LisaPlayer player;//それぞれのキャラクターの型で宣言しておかないと
  //キャラクターごとに記述した関数を呼び出せないのでStateクラスの子であるLisaStateでわざわざ宣言した
  //よって状態間でロジックが被ることがあってもキャラごとに書かなくてはいけなくなり保守性とかが低下した
  void changeState(State nextState){
    if(nextState==null)return;
    player.changeState(nextState);

  }
  //コマンド分岐
  State commandBrunching(){
    if(player.keyState[4]!=1)return null;
    Integer[] input = player.command.now();

    if(commandDetection(input, 1+player.direction, 1, 1-player.direction)){//コマンド入力リストの後ろから
      //第2,第3,...引数のキーに応じたコマンドを入力リストから合致するか探索、
      //リストの一番後ろが指定した型と一致する場合
      return new LisaShootBulletState(player);
    }
    if(commandDetection(input, 1-player.direction, 1, 1+player.direction)){//コマンド入力リストの後ろから
      return new LisaShootBackState(player);
    }
    return null;

  }
  //ふつうの状態に戻る時にだいたい実行する処理群をここに記述。
  void defaultBrunching(){
    if(player.stateBuffer!=null){
      changeState(player.stateBuffer);
      player.stateBuffer=null;
      player.stateBufCount=-1;
    }
    else if(player.isGrounding==0){
      changeState(new LisaJumpState(player));return;
    }
    else if(player.keyState[0]>0 && player.keyState[2]==0){//右キー入力
      if(player.direction==-1 && player.isConfronting)changeState(new LisaGuardState(player));
      else changeState(new LisaWalkState(player));return;
    }
    else if(player.keyState[0]==0 && player.keyState[2]>0){//左キー入力
      if(player.direction== 1 && player.isConfronting)changeState(new LisaGuardState(player));
      else changeState(new LisaWalkState(player));return;
    }
    else if(player.keyState[1]>0){
    changeState(new LisaSquatState(player));return;
    }
    else if(player.keyState[3]>0){
    changeState(new LisaJumpState(player));return;
    }
    if(player.sensorState==1){//センサーの入力
      changeState(new LisaCounterWaitState(player));return;
    }
    else{
      changeState(new LisaIdolState(player));return;
    }
  }
  //前のメインループでダメージを受けた時の分岐。[相手のダメージタイプ]＋[受容タイプ]の計算値を用いる。
  boolean damageBrunching(int receiveType){
    if(player.damaged==0)return false;
    if(player.isGrounding==0)receiveType++;
    println("damaged:" + (player.damaged+receiveType));
    switch(max(0,min(player.damaged+receiveType,2))){
      case 0:changeState(new LisaGuardRigorState(player));return true;
      case 1:changeState(new LisaBeHitLState(player));return true;
      case 2:changeState(new LisaBeHitHState(player));return true;
    }
    return false;
  }
}

//以下状態分岐

//待機状態
class LisaIdolState extends LisaState{
  LisaIdolState(LisaPlayer player_){
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
      if(player.direction==-1 && player.isConfronting){changeState(new LisaGuardState(player));return;}
      else changeState(new LisaWalkState(player));
    }
    else if(player.keyState[0]==0 && player.keyState[2]>0){//左キー入力
      if(player.direction== 1 && player.isConfronting){changeState(new LisaGuardState(player));return;}
      else changeState(new LisaWalkState(player));
    }
    else{
      //player.actNoMove();
    }

    if(keyState[1]>1){
      changeState(new LisaSquatState(player));return;
    }
    if(keyState[3]==1){
      changeState(new LisaJumpState(player));return;
    }

    if(keyState[4]==1){
      changeState(new LisaPunchState(player));return;
    }
    if(keyState[5]==1){
      changeState(new LisaFlipState(player));return;
    }
    if(player.sensorState==1){
      changeState(new LisaCounterWaitState(player));return;
    }
  }
  PImage drawSprite(PImage[] images){
    int fps = 9;
    if(frames%(images.length*fps)==4*fps){
      effectsHolder.add(new Effect(effectsHolder, effectDataArea[player.no+1],
      "LittleDust", new Object(null, player.x+player.wid/2, player.y+player.hig)));
    };
    return loopAnimation(images, fps);
  }
}
//歩く
class LisaWalkState extends LisaState{
  int direction_;
  LisaWalkState(LisaPlayer player_){
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
      if(player.direction==-1 && player.isConfronting){changeState(new LisaGuardState(player));return;}
      player.actMoveRight();
      if(player.direction==-1)direction_ = 1;
      else direction_ = 0;
    }
    else if(keyState[0]==00 && keyState[2]>0){
      if(player.direction== 1 && player.isConfronting){changeState(new LisaGuardState(player));return;}
      player.actMoveLeft();
      if(player.direction== 1)direction_ = 1;
      else direction_ = 0;
    }

    else {
      changeState(new LisaIdolState(player));return;}

    if(keyState[1]>1){
      changeState(new LisaSquatState(player));return;
    }
    if(keyState[3]==1){
      changeState(new LisaJumpState(player));return;
    }

    if(keyState[4]==1){
      changeState(new LisaKickState(player));return;
    }
    if(keyState[5]==1){
      Player otherPlayer = player.stage.player[(player.no+1)%2];
      if(otherPlayer.collider.colliding(new Collider(player.stage, (Player)player, player.wid/2-10, player.hig/2-player.hig/2, 20, player.collider.hig, 1, false, false))){
        //指定したcolliderと相手のcolliderが接していた時
        changeState(new LisaThrowState(player, otherPlayer));println("つかみ発生");return;
      }
      else{
        changeState(new LisaFlipState(player));return;
      }
    }
    if(player.sensorState==1){
      changeState(new LisaCounterWaitState(player));return;
    }
  }
  PImage drawSprite(PImage[] images){
    //プレイヤーの向いてる向きに応じて前半の画像、後半の画像のいずれかを読み込む
    int fps = 10;
    frames = (frames+1)%(images.length/2*fps);
    return images[((frames/fps)%(images.length/2)) + images.length/2*direction_];
  }
}
//ガード
class LisaGuardState extends LisaState{
  LisaGuardState(LisaPlayer player_){
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
      changeState(new LisaIdolState(player));return;}

    if(keyState[1]>1){
      changeState(new LisaSquatState(player));return;
    }
    if(keyState[3]==1){
      changeState(new LisaJumpState(player));return;
    }

    if(keyState[4]==1){
      changeState(new LisaPunchState(player));return;
    }
    if(keyState[5]==1){
      changeState(new LisaFlipState(player));return;
    }
    if(player.sensorState==1){
      changeState(new LisaCounterWaitState(player));return;
    }
    player.isGuard = true;
    //player.actNoMove();
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 6);
  }
}
//しゃがむ
class LisaSquatState extends LisaState{
  LisaSquatState(LisaPlayer player_){
    player = player_;
    no = 5;
    count = 0;
    limit = -1;
  }
  void startUp(){
  }

  void update(int[] keyState){
    countUp();//カウントする
    player.collider.resetSize();
    if(damageBrunching(0))return;
    if(commandBrunching()!=null){changeState(commandBrunching());return;}
    if(keyState[1]==0){
      if(player.keyState[0]>0 && player.keyState[2]==0){//右キー入力
        if(player.direction==-1 && player.isConfronting){changeState(new LisaGuardState(player));return;}
        else changeState(new LisaWalkState(player));return;
      }
      else if(player.keyState[0]==0 && player.keyState[2]>0){//左キー入力
        if(player.direction== 1 && player.isConfronting){changeState(new LisaGuardState(player));return;}
        else changeState(new LisaWalkState(player));return;
      }
      else {
        changeState(new LisaIdolState(player));return;
      }
    }
    if(keyState[3]==1){
      changeState(new LisaJumpState(player));return;
    }

    if(keyState[4]==1){
      changeState(new LisaTrippedState(player));return;
    }
    if(keyState[5]==1){
      changeState(new LisaFlipState(player));return;
    }
    if(player.sensorState==1){
      changeState(new LisaCounterWaitState(player));return;
    }
    player.collider.resize(player.wid/2, player.hig*3/4, player.wid*8/10, player.hig/2);
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 4);
  }
}
//ジャンプ
class LisaJumpState extends LisaState{
  LisaJumpState(LisaPlayer player_){
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
      changeState(new LisaLandState(player));return;
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
      //ジャンプ中のコマンド入力の受付
      if(commandDetection(player.command.now(), 1, 3)){//コマンド入力リストの後ろから
        changeState(new LisaWhirlwindKickState(player));return;
      }

      changeState(new LisaJumpKickState(player));return;
    }
    if(keyState[5]==1){
      changeState(new LisaFlipState(player));return;
    }
    if(player.sensorState==1){
      changeState(new LisaCounterWaitState(player));return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 3);
  }
}
//着地
class LisaLandState extends LisaState{
  LisaLandState(LisaPlayer player_){
    player = player_;
    no = 8;
    count = 0;
    limit = 5;
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
//パンチ
class LisaPunchState extends LisaState{
  LisaPunchState(LisaPlayer player_){
    player = player_;
    no = 9;
    count = 0;
    limit = 16;
  }
  void startUp(){
    //player.actPunch();
  }

  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    if(count==8)player.actPunch();
    if(count==limit){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 7);
  }
}
//キック
class LisaKickState extends LisaState{
  LisaKickState(LisaPlayer player_){
    player = player_;
    no = 10;
    count = 0;
    limit = 24;
  }
  void startUp(){
    //player.actKick();
  }

  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;
    if(count==8)player.actKick();
    if(count==limit){
      defaultBrunching();return;
    }
    player.actDurKick();
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 7);
  }
}
//ジャンプキック
class LisaJumpKickState extends LisaState{
  LisaState stateBuffer;
  LisaJumpKickState(LisaPlayer player_){//キャラ特有の動きを作る場合はとる引数の型を指定する
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
      changeState(new LisaLandState(player));return;
    }
  }
  PImage drawSprite(PImage[] images){
    return loopAnimation(images, 5);
  }
}
//足払い
class LisaTrippedState extends LisaState{
  LisaTrippedState(LisaPlayer player_){//キャラ特有の動きを作る場合はとる引数の型を指定する
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
    return straightAnimation(images, 5);
  }
}
//反転
class LisaFlipState extends LisaState{
  LisaFlipState(LisaPlayer player_){
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
//弾打つ
class LisaShootBulletState extends LisaState{
  LisaShootBulletState(LisaPlayer player_){
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

    if(count==14)player.actShootBullet();

    if(count==limit){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 7);
  }
}
//後ろに弾打つ
class LisaShootBackState extends LisaState{
  LisaShootBackState(LisaPlayer player_){
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

    if(count==13)player.actShootBack();

    if(count==limit){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 8);
  }
}
//回転
class LisaWhirlwindKickState extends LisaState{
  LisaWhirlwindKickState(LisaPlayer player_){
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
    if(count%2==0)effectsHolder.add(new Effect(effectsHolder, effectDataArea[player.no+1],
      "SpinWind", new Object(null, player.x+player.wid/2, player.y+player.hig/2+20)));

    if(count==limit||player.isGrounding>0){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    return loopAnimation(images, 3);
  }
}
//ガード中に被弾した時の怯み
class LisaGuardRigorState extends LisaState{
  LisaGuardRigorState(LisaPlayer player_){
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
//ノックバック弱
class LisaBeHitLState extends LisaState{
  LisaBeHitLState(LisaPlayer player_){
    player = player_;
    no = 2;
    count = 0;
    limit = 10;
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
    return straightAnimation(images, 4);
  }
}
//ノックバック強
class LisaBeHitHState extends LisaState{
  LisaBeHitHState(LisaPlayer player_){
    player = player_;
    no = 1;
    count = 0;
    limit = -1;
  }
  void startUp(){
  }

  void update(int[] keyState){
    countUp();//カウントする
    if(player.isGrounding>0){
      player.damaged = 0;
      changeState(new LisaBeStruckState(player));return;
    }
    //player.actNoMove();
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 3);
  }
}
//掴まれたとき
class LisaBeHeldState extends LisaState{
  LisaBeHeldState(LisaPlayer player_){
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
//地面に倒れこむ
class LisaBeStruckState extends LisaState{
  LisaBeStruckState(LisaPlayer player_){
    player = player_;
    no = 0;
    count = 0;
    limit = 15;
  }
  void startUp(){
  }

  void update(int[] keyState){
    countUp();//カウントする
    if(count==limit&&player.hp>0){//
      defaultBrunching();return;
    }
    //player.actNoMove();
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 3);
  }
}
//カウンター待機
class LisaCounterWaitState extends LisaState{//
  LisaCounterWaitState(LisaPlayer player_){
    player = player_;
    no = 5;
    count = 0;
    limit = 20;
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
    return fullAnimation(images);
  }
}
//カウンター
class LisaCounterState extends LisaState{//全員必要
  LisaCounterState(LisaPlayer player_){
    player = player_;
    no = 17;
    count = 0;
    limit = 20;
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
    return straightAnimation(images, 7);
  }
}
//弾を跳ね返す
class LisaCounterBulletState extends LisaState{
  Bullet otherBullet;
  LisaCounterBulletState(LisaPlayer player_, Bullet otherBullet_){
    player = player_;
    no = 17;
    count = 0;
    limit = 15;
    otherBullet = otherBullet_;
  }
  void startUp(){
  }

  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0))return;

    if(count==5)otherBullet.filpHlizon((Player)player);

    if(count==limit){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    return loopAnimation(images, 3);
  }
}
//つかんで投げる
class LisaThrowState extends LisaState{//全員必要
  Player otherPlayer;
  LisaThrowState(LisaPlayer player_, Player otherPlayer_){
    player = player_;
    no = 19;
    count = 0;
    limit = 45;
    otherPlayer = otherPlayer_;
  }
  void startUp(){
    player.actHoldOther(otherPlayer);
  }

  void update(int[] keyState){
    countUp();//カウントする
    if(damageBrunching(0)){
      otherPlayer.beFree();return;
    }

    if(count==20){
      player.actThrowOther(otherPlayer);
    }

    if(count==limit){
      defaultBrunching();return;
    }
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, 10);
  }
}