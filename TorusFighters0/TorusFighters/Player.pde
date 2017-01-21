//Player、State、Collider、Bullet、Objectクラスについて実装
//担当:森口

class Player extends Object{
  String name;//ファイル読み込みとかで整合性をとるためにString型のおなまえを用意
  PImage[][][] images;//向き/状態数/コマ数 で初期化された画像アドレスの配列
  final int TYPE_AHEAD_LIMIT = 13;//先行入力の受付時間
  //特性を表す変数
  int no;
  int wid = 120;
  int hig = 260;
  final double VX_MAX = 2.7;
  final double VY0 = 12;
  final double GRAVITY = 0.5;
  final int SEARCH_OPERATION_RANGE = 400;
  final int MAX_HP = 120;
  Collider collider;//判定を保持しておく
  Stage stage;

  //状態を表す変数
  State state;
  State stateBuffer;
  int stateBufCount;//TYPE_AHEAD_LIMIT
  int hp = MAX_HP;
  int direction;
  boolean isConfronting = false;
  boolean isGuard = false;
  boolean isHeld = false;
  int isGrounding = 0;//0:空中, 1:着地直後, 2:着地（直後を除く）のいずれかをとる
  int damaged = 0;    //0:ダメージなし, 1:被弾弱, 2:被弾強のいずれかをとる
  double vx;
  double vy;
  double knockbackx;
  double knockbacky;
  int[] keyState = new int[6];
  int sensorState;
  Command command;

  Player(){}

  void init(Stage stage_, int no_){
    //state = new IdolState(this);
    no = no_;
    stage = stage_;
    for(int i=0;i<6;i++)keyState[i]=0;
    float x_,y_;
    switch(no){
      case 0:x_ = 40;direction = 1;break;
      default:x_ = width-wid-40;direction = -1;break;
    }
    y_ = stage.horizon-hig;
    replace(null,x_,y_);
    collider = new Collider(stage, this, wid/2, hig/2, wid*8/10, hig*8/10, -1, false, true);
    command = new Command();
    vx = 0;
    vy = 0;
  }

  //処理しようとしているキー入力の状態を更新する
  //0~6の順で、右、下、左、上、Z、Xキー、センサー入力に対応している
  //いずれも入力がある時インクリメントし続け、ない時はずっと0
  void inputKey(int keyState_){
    if((keyState_&1)==1)  keyState[0]++; else keyState[0]=0;
    if((keyState_&2)==2)  keyState[1]++; else keyState[1]=0;
    if((keyState_&4)==4)  keyState[2]++; else keyState[2]=0;
    if((keyState_&8)==8)  keyState[3]++; else keyState[3]=0;
    if((keyState_&16)==16)keyState[4]++; else keyState[4]=0;
    if((keyState_&32)==32)keyState[5]++; else keyState[5]=0;
    if((keyState_&64)==64)sensorState++; else sensorState=0;
  }

  void update(){
    //対面状態の判定
    if(stage.collisionalDetect(this, new Collider(stage, this, direction*SEARCH_OPERATION_RANGE/2 , 0, SEARCH_OPERATION_RANGE, stage.stageHeight*2, 1, false, false)))
    isConfronting=true;
    else isConfronting = false;

    command.update(keyState);
    gainTypeAhead();

    state.update(keyState);
    if(state.count==0)state.startUp();

    pysicalMovement();
    if(damaged == 0)stage.collisionalDetect(this);
  }

  //先行入力の取得、破棄を行う
  void gainTypeAhead(){
    if(state.commandBrunching()!=null){
      stateBuffer = state.commandBrunching();
      stateBufCount=0;
    }
    if(stateBufCount>-1){
      stateBufCount++;
      if(stateBufCount==TYPE_AHEAD_LIMIT){
        stateBufCount=-1;
        stateBuffer=null;
      }
    }
  }
  //落下、移動、着地を行う
  void pysicalMovement(){
    vx += knockbackx;
    vy += knockbacky;
    vy += GRAVITY;

    knockbackx *= 0.23;
    knockbacky *= 0.23;
    x += vx;
    y += vy;
    if(isGrounding>0)vx = 0.5 * vx;
    stage.EndPointCollision(this);
  }

  //振る舞いを関数として提供、act[英単語]()の形で
  //主にどこでも呼ばれるもの
  //着地中ならvyをいじる
  void actJump(){
    if(isGrounding>0){vy = -VY0;
      effectsHolder.add(new Effect(effectsHolder, effectDataArea[0],
      "DustFlowL", new Object(null, x+wid/2, y+hig)));
    }
  }
  //前に進むときは速く、後ろに進むときは遅く
  void actMoveRight(){
    if(direction==1) vx = direction*VX_MAX;
    else             vx = -direction*VX_MAX*2.0/3.0;}
  void actMoveLeft(){
    if(direction==-1)vx = direction*VX_MAX;
    else             vx = -direction*VX_MAX*2.0/3.0;
  }
  //掴み
  void actHoldOther(Player o){
    direction=-direction;
    o.beHeld();
    o.replace(null, x+wid*(1-direction)/2-o.wid/2, o.y);
  }
  //投げる
  void actThrowOther(Player otherPlayer){
    otherPlayer.vy=-5;
    Collider added = addCollider(0, 0, wid, hig/3, 2);
    added.attackType = 2;
  }

  void beHeld(){//必ずオーバーライド
  }
  void beFree(){//必ずオーバーライド
  }

  //当たり判定を追加する。
  //第一、第二引数で自身の中心座標から判定の中心座標までの相対座標を指定、
  //第三、第四引数で判定の大きさ
  //第五引数に制限時間を指定
  Collider addCollider(int cx_, int cy_, int wid_, int hig_, int countLimit_){
    Collider newCollider = new Collider(stage, this, direction, 1, 10, wid/2+cx_ , hig/2+cy_, wid_, hig_, countLimit_, true, false);
    stage.colliderList.add(newCollider);
    println("added collider");
    return newCollider;
  }
  //自身から離れて動く当たり判定を追加する。
  //同上
  //第六、第七引数にx,y方向の速度を指定
  Bullet addBullet(int cx_, int cy_, int wid_, int hig_, int countLimit_, float vx_, float vy_){
    Bullet newBullet = new Bullet(stage, this, direction, 2, 10, wid/2+cx_ , hig/2+cy_, wid_, hig_, countLimit_, true, false, vx_, vy_);
    stage.colliderList.add(newBullet);
    println("added collider");
    return newBullet;
  }
  //自身から離れて動く当たり判定を追加する。
  //第一引数にbulletの向き
  //同上
  Bullet addBullet(int direction_, int cx_, int cy_, int wid_, int hig_, int countLimit_, float vx_, float vy_){
    Bullet newBullet = new Bullet(stage, this, direction_, 2, 10, wid/2+cx_ , hig/2+cy_, wid_, hig_, countLimit_, true, false, vx_, vy_);
    stage.colliderList.add(newBullet);
    println("added collider");
    return newBullet;
  }

  //colliderを受け取ってそれに応じたダメージを受け取る。
  void getDamage(Collider other){
    other.corruption();
    int damage = other.damage;
    direction = -other.direction;
    if(isGuard)damage=(int)((float)damage*0.2);
    vx = knockbackx = (float)damage*other.direction*0.5;//ノックバック速度を決定
    hp -= damage;//hpを減らす
    if(hp<0){
      vy = -6;
      damaged = 3;
      stage.gameEndCount=0;
      //stage側に終了するようメッセージを出す
      stage.inputEnabled=false;
    }
    else{
      damaged = other.attackType;
    }
    //エフェクトの再生
    effectsHolder.add(new Effect(effectsHolder, effectDataArea[0],
      "SparkL", new Object(null, other.asWorld().x+other.wid/2, other.asWorld().y+other.hig/2)));
    isGuard = false;
    //state.changeState(new BeHitState1(this));
  }

  void changeState(State nextState){
    state = nextState;
  }

  void display(int scrollX, int scrollY){
    PImage sprite = null;
    if(images!=null) sprite = state.drawSprite(images[(int)((1-direction)/2)][state.no]);

    stroke(255);
    strokeWeight(1);
    fill(180-180*no,220-120*no,220*no);
    if(sprite!=null){
      image(sprite, asWorld().x-scrollX-(sprite.width-wid)/2,asWorld().y-scrollY-(sprite.height-hig)/2);
    }
    else {
      rect(asWorld().x-scrollX,asWorld().y-scrollY,wid,hig);
    }
    if(consoleForDebug){
      ellipse(asWorld().x+(1+direction)*wid/2,asWorld().y+hig/6, 10,10);
      fill(0,200,0,70);
      stroke(80,255,80,80);
      strokeWeight(1);
      rect(collider.asWorld().x,collider.asWorld().y,collider.wid,collider.hig);
      fill(255,255,255,230);

      Integer[] com = command.now();
      String comStr = "";
      for(int i = 0; i<com.length; i++){
        comStr += "" + com[i] + " ";
      }

      if(sprite==null)text(state.no,asWorld().x+wid/2-5,asWorld().y+hig/2-5);
      text("state.no:"+ state.no + "\n " +
      "state.count:" + state.count + "\n\n" +
      "command:" + comStr + "\n" +
      "isConfronting:" + isConfronting + "\n" +
      "isGuard:" + isGuard + "\n" +
      "sensorState:" + sensorState + "\n" +
      "",
      asWorld().x+wid,asWorld().y);
      fill(0,0,0,150);
      rect(asWorld().x+wid,asWorld().y+20,70,10);
      fill(255,255,255,230);
      if(state.limit>0)rect(asWorld().x+wid,asWorld().y+20,70*(1-pow((1-(float)state.count/state.limit),2)),10);
      else{ fill(250,255,130,230);rect(asWorld().x+wid,asWorld().y+20,70,10);}
    }
  }

}

//Stateパターン。 キャラごとのStateに継承する。
class State {
  //Player player;
  int no;//状態の通し番号。一応。
  int count;//カウントを記録
  int frames;//アニメーション時に利用するカウント
  int limit;
  State(){}
  //はじめに一度だけ
  void startUp(){
    println("This state(" + no + ")'s startUp() is not overwtitten");
    int[] er = new int[1];
    er[100]=0;
  }
  //状態ごとの処理を実際にここに書く
  void update(int[] keyState){
    println("This state(" + no + ")'s update() is not overwtitten");
    int[] er = new int[1];
    er[100]=0;
  }
  //びょうがする時の画像の扱い方についてここに書く
  PImage drawSprite(PImage[] images){
    println("This state(" + no + ")'s drawSplite() is not overwtitten");
    int[] er = new int[1];
    er[100]=0;
    return null;
  }

  State commandBrunching(){
    return null;
  }

  void changeState(State nextState){
    //player.changeState(nextState);
    //都合によりplayerをベースクラスで保持できなかったのであきらめた
  }
  //カウント
  void countUp(){
    if(limit!=-1)count=(count+1)%(limit+1);//上限がある状態についてカウントを増やす
    else {
      if(count==0)count=1;
      else count=2;//上限がないものは0→1→2に増やして、以降ずっと2のままにする
    }
  }
  //画像ループ
  PImage loopAnimation(PImage[] images, int fps){
    frames = (frames+1)%(images.length*fps);
    return images[(frames/fps)%images.length];
  }
  //いちどっきり再生
  PImage straightAnimation(PImage[] images, int fps){
    frames = min((images.length*fps-1),(frames+1));
    return images[(frames/fps)%images.length];
  }
  //limitまで、全ての画像を同じ速度で再生する
  PImage fullAnimation(PImage[] images){
    if(limit==-1)return null;//これはエラーを吐く
    float fps = limit/images.length;
    frames = min((int)(images.length*fps),(frames+1));
    return images[(int)(frames/fps)%images.length];
  }

  //コマンドリストの最後から見比べて入力された型との比較を行う
  boolean commandDetection(Integer[] input, Integer... mold){
    if(input.length<mold.length)return false;
    int inpLast = input.length-1;
    for(int i = mold.length-1; i > -1; i--){
      ///println("check\""+input[inpLast-i]+":"+mold[mold.length-1-i]+"\"");
      if(input[inpLast-i]!=mold[mold.length-1-i])return false;
    }
    return true;
  }
}
//実働する一つの当たり判定を表す。
//stageのインスタンスにこれらの当たり判定を保有するリストがある
class Collider extends Object{
  float X, Y;
  int WID, HIG;
  int direction;
  int attackType;
  int damage;
  int wid,hig;
  int count;
  int countLimit;
  boolean attackable;//true:他Colliderに攻撃できる(damageable:trueのものに対してのみ)
  boolean damageable;//true:他Colliderからの攻撃を受ける(attackable:trueのものに対してのみ)
  boolean terminateReady = false;
  Player parent;
  Stage stage;
  boolean extinctFlag;
  LinkedList<Collider> attackedList = new LinkedList<Collider>();

  Collider(){}
  Collider(Stage stage_, Player parent_, float cx_, float cy_, int wid_, int hig_, int countLimit_, boolean attackable_, boolean damageable_){
    stage = stage_;
    parent = parent_;
    //座標rootを親playerに設定、判定はplayerと一緒に動く
    replace(parent_, cx_ - wid_/2, cy_ - hig_/2);
    wid = wid_;
    hig = hig_;
    X=x;Y=y;WID=wid;HIG=hig;
    count = 0;
    countLimit = countLimit_;//-1をとる
    attackable = attackable_;
    damageable = damageable_;
    extinctFlag = false;
  }

  Collider(Stage stage_, Player parent_, int direction_, int attackType_, int damage_, float cx_, float cy_, int wid_, int hig_, int countLimit_, boolean attackable_, boolean damageable_){
    stage = stage_;
    parent = parent_;
    direction = direction_;
    damage = damage_;
    attackType = attackType_;
    replace(parent_, cx_ - wid_/2, cy_ - hig_/2);
    wid = wid_;
    hig = hig_;
    count = 0;
    countLimit = countLimit_;//-1をとる
    attackable = attackable_;
    damageable = damageable_;
    extinctFlag = false;
  }

  void resize(float cx_, float cy_, int wid_, int hig_){
    replace(parent, cx_ - wid_/2, cy_ - hig_/2);
    wid = wid_;
    hig = hig_;
  }
  void resetSize(){
    x=X;y=Y;wid=WID;hig=HIG;
  }

  //戻り値にtrueを返すとそのColliderは消滅する
  boolean update(){
    if(terminateReady)return true;
    if(!extinctFlag)extinctFlag=true;
    else if(parent.state.count==0&&root!=null)return true;
    if(count==countLimit)return true;
    count++;
    return false;
  }

  void display(){
    //恐らく最終的には使用しない、デバッグ用に表示する
    if(consoleForDebug){
      fill(200,0,0,150);
      stroke(255,80,80,200);
      strokeWeight(1);
      rect(stage.loopCoor(asWorld().x),asWorld().y,wid,hig);
    }
  }

  void corruption(){
    println("collider corruption");
  }

  //トーラス上での２つの四角形の衝突を判定、正否を返す
  boolean colliding(Collider otherC){
    int sw = stage.stageWidth;
    int sh = stage.stageHeight;
    float orgX0 = (asWorld().x+sw)%sw;
    float orgX1 = (asWorld().x+wid+sw)%sw;
    float othX0 = (otherC.asWorld().x+sw)%sw;
    float othX1 = (otherC.asWorld().x+otherC.wid+sw)%sw;
    if(orgX1<orgX0&&othX1<othX0){orgX1+=sw;othX1+=sw;}
    if(orgX1<orgX0&&othX1>othX0){
      if(orgX0>othX1)orgX0-=sw;
      else           orgX1+=sw;}
    if(orgX1>orgX0&&othX1<othX0){
      if(othX0>orgX1)othX0-=sw;
      else           othX1+=sw;}
    float orgY0 = (asWorld().y+sh)%sh;
    float orgY1 = (asWorld().y+hig+sh)%sh;
    if(orgY1<orgY0)orgY1+=sh;
    float othY0 = (otherC.asWorld().y+sh)%sh;
    float othY1 = (otherC.asWorld().y+otherC.hig+sh)%sh;
    if(othY1<othY0)othY1+=sh;

    if(orgX0<othX1 && orgX1>othX0 &&
    asWorld().y<otherC.asWorld().y+otherC.hig && asWorld().y+hig>otherC.asWorld().y)return true;

    //if(asWorld().x<otherC.asWorld().x+otherC.wid && asWorld().x+wid>otherC.asWorld().x &&
    //asWorld().y<otherC.asWorld().y+otherC.hig && asWorld().y+hig>otherC.asWorld().y)return true;
    return false;
  }
}

//playerとは離れて移動するbulletをクラス。
class Bullet extends Collider{
  float vx;
  float vy;
  int extinctionCount;
  int extinctionLimit;
  Effect effect;
  Bullet(Stage stage_, Player parent_, int direction_, int attackType_, int damage_, float cx_, float cy_, int wid_, int hig_, int countLimit_, boolean attackable_, boolean damageable_, float vx_, float vy_){
    stage = stage_;
    parent = parent_;
    direction = direction_;
    damage = damage_;
    attackType = attackType_;
    //rootをnull、ワールド座標で処理する
    replace(new Object(parent, cx_ - wid_/2, cy_ - hig_/2).asWorld());
    wid = wid_;
    hig = hig_;
    count = 0;
    countLimit = countLimit_;//-1をとる
    attackable = attackable_;
    damageable = damageable_;
    extinctFlag = false;
    vx = vx_;
    vy = vy_;
  }

  boolean update(){
    x += vx;
    y += vy;
    boolean ref = super.update();
    return ref;
  }

  //消滅するときエフェクトにメッセージを送る
  void corruption(){
    println("bullet corruption");
    if(effect!=null)if(effect.behavior!=null)effect.behavior.message();

  }

  //反転させたい時に外部から呼び出す
  void filpHlizon(Player nextParent){
    vx=-vx;
    direction = -1;
    parent = nextParent;
    count = 0;
  }
}

//親子関係を持つ位置ベクトル(2点間の位置ベクトル)
class Object{
  Object root;
  float x;//rootのローカル座標として振る舞う
  float y;//root==nullのときワールド座標として振る舞う
  //外部から普通呼ばない
  void replace(Object root_, float x_, float y_){
    root = root_;
    x = x_;
    y = y_;
  }
  void replace(Object other){
    root = other.root;
    x = other.x;
    y = other.y;
  }
  Object(){replace(null, 0, 0);}
  Object(Object root_, float x_, float y_){replace(root_, x_, y_);}
  Object(Object other){replace(other);}
  Object(Object root_, Object other){
    Object obj_ = other;
    obj_.setRoot(root_);
    replace(obj_);
  }

  Object add(Object other){return new Object(root, x+other.x, y+other.y);}
  Object sub(Object other){return new Object(root, x-other.x, y-other.y);}

  Object asOnOne(){
    if(root==null)return null;
    return new Object(root.root, root.x+x, root.y+y);
  }

  void setRoot(Object nextRoot){
    root = nextRoot;
    replace(this.asWorld().sub(nextRoot.asWorld()));
  }

  Object asWorld(){
    Object obj_ = this;
    for(;obj_.asOnOne() != null;){
      obj_ = obj_.asOnOne();
    }
    return obj_;
  }

  float asWorldx(){
    return this.asWorld().x;
  }
  float asWorldy(){
    return this.asWorld().y;
  }
}