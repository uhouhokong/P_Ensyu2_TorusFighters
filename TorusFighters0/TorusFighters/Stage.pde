//Stage、NetworkConnector及び以下クラス、Command、NowKey、TrainingRoom、CharaChoiceforTrainingクラスについて実装
//担当:森口

import java.util.LinkedList;
import java.util.Iterator;

//player同士、collider同士などの相互の作用をまとめて管理する
class Stage extends Scene{
  int horizon;
  NetworkConnector NConnect;

  int playerNo;

  int keyStateOppo = 0;
  LinkedList<Collider> colliderList;//当たり判定リスト
  boolean inputEnabled = true;
  int gameEndCount = -1;
  PImage[] gameEndImg;


  //グローバル領域でアドレスを確保
  //本当はStageのインナークラスとしてPlayerなど定義できていれば良かった？
  //EffectDataArea staticEffectDataArea;
  //EffectDataArea[] dinamicEffectDataArea = new EffectDataArea[2];
  //EffectsHolder effectsHolder;

  PImage background;
  int stageWidth = 640;
  int stageHeight = 600;
  float lookAtX = 0;
  float lookAtY = 0;
  float scrollX = lookAtX;
  float scrollY = lookAtY;

  Player[] player= new Player[2];
  void startUp(){
  }

  Stage(){}
  Stage(PApplet applet_, NetworkConnector NConnect_, Player p0, Player p1){
    horizon = height-50;
    colliderList = new LinkedList<Collider>();
    parent = applet_;
    NConnect = NConnect_;
    if (NConnect instanceof ServerControler)playerNo = 0;
    else playerNo = 1;
    //Playerの設定
    player[playerNo] = p0;
    player[(playerNo+1)%2] = p1;
    player[playerNo].init(this, playerNo);
    player[(playerNo+1)%2].init(this, (playerNo+1)%2);
    //EffectDataAreaの設定
    effectDataArea[0] = new EffectDataArea("../../image/Effect");//同一の領域
    //プレイヤーごとに新しく確保する領域、同じキャラクターならインスタンスは1つだけ作る
    effectDataArea[1] = new EffectDataArea("../../image/"+player[0].name+"/Effect");
    if(player[0].name==player[1].name) effectDataArea[2] = effectDataArea[1];
    else effectDataArea[2] = new EffectDataArea("../../image/"+player[1].name+"/Effect");
    effectsHolder = new EffectsHolder();

    //プレイヤーを識別するためのリングを表示する
    effectsHolder.add(new Effect(effectsHolder, effectDataArea[0],
    "RingB", new Object(player[0], player[0].wid/2, player[0].hig-50)));
    effectsHolder.add(new Effect(effectsHolder, effectDataArea[0],
    "RingR", new Object(player[1], player[1].wid/2, player[1].hig-50)));
    initBackground(loadImage("../../image/background.png"));

    //gameEnd(急ごしらえ)
    gameEndImg = new PImage[4];
    for(int i=0;i<gameEndImg.length;i++){
      gameEndImg[i] = loadImage("../../image/Effect/GameSet/"+NumtoString(3, i) + ".png");
    }
    //gameEnd(急ごしらえ)
    println("reached Stage() as" + playerNo);
  }

  void initBackground(PImage background_){background = background_;}

  void update(){
    //描画重さの切り替え
    if(keyCode==SHIFT){
      if(!drawLighter)initBackground(loadImage("../../image/background.png"));
      else initBackground(loadImage("../../image/backgroundd_.png"));
    }
    //データ同期
    if(NConnect!=null)if(!syncData())return;

    //操作可能なら入力を受け付け
    if(inputEnabled){
      String formatBuf = strShorten(str(keyStateThis));
      player[playerNo].inputKey(int(formatBuf));
      player[(playerNo+1)%2].inputKey(keyStateOppo);
    }
    else{
      player[playerNo].inputKey(0);
      player[(playerNo+1)%2].inputKey(0);
    }
    player[0].update();
    player[1].update();
    //当たり判定リストの走査
    //探索中に要素を削除する可能性があるので自分でイテレータを進める
    for(Iterator it = colliderList.iterator(); it.hasNext(); ) {
      Collider element = (Collider)it.next();
      if(element.update()) {
        it.remove();
      }
    }
    //エフェクトのupdate
    effectsHolder.update();
    //描画
    display();
    //ゲーム終了時のUI（急ごしらえ）
    if(gameEndCount!=-1)gameEndLoop();
  }

  //
  boolean syncData(){
    //次ループで送信するデータの代入
    String formatBuf = strShorten(str(keyStateThis));
    NConnect.writeLine(""+formatBuf);
    //受信と送信を同時に行う
    String ref = NConnect.toSyncBuffer();
    if(ref==null)return false;
    String[] buf = ref.split(",");
    if(buf[0]!=null)keyStateOppo = int(buf[0]);
    return  true;
  }

  void gameEndLoop(){
    resetMatrix();
    int frame = max(gameEndCount, 14)-15;
    if(frame>-1){
      PImage nextImage = straightAnimation(frame, gameEndImg, 4);
      int wid = nextImage.width;
      int hig = nextImage.height;
      image(nextImage, width/2-wid/2, height/2-hig/2);
    }
    if(gameEndCount == 90){
      //選択画面に戻る
      if(NConnect!=null){
        changeScene(new CharaChoice(parent, NConnect, keyState));return;
      }
      else{
        changeScene(new CharaChoiceforTraining(parent, keyState));return;
      }
    }
    gameEndCount++;
  }

  //一度だけ再生
  PImage straightAnimation(int count_, PImage[] images, int fps){
    int frames = min((images.length*fps-1),(count_));
    return images[(frames/fps)%images.length];
  }

  void display(){
    background(120);
    //プレイヤー間の距離
    float dist = max(abs(player[0].x-player[1].x-player[1].wid),
                     abs(player[0].x+player[0].wid-player[1].x));
    // float scale = (float)abs(dist)/width;
    // if(scale<1)scale=1.0;
    //スクロールを計算する
    lookAtX = (int)min(player[0].x,player[1].x);
    lookAtX-=(width-dist)/2;
    float Dist = (player[(1+playerNo)%2].x+player[(1+playerNo)%2].wid/2) - (player[playerNo].x+player[playerNo].wid/2);
    float preLookAtX = lookAtX;
    float naturalDistance = -width/2+player[playerNo].wid/2;
    naturalDistance += Dist/2;
    lookAtX = player[playerNo].x+naturalDistance;//+stageWidth)%stageWidth;

    //複製して描画する画像の方向を計算
    int dupliDirect = -1;
    if(abs(lookAtX-preLookAtX)>width/2){
      scrollX+=sgn(lookAtX-preLookAtX)*stageWidth;
    }

    scrollX -= (scrollX-lookAtX)*0.2;
    scrollY -= (scrollY-lookAtY)*0.2;

    if(abs(loopCoor(scrollX-naturalDistance)-loopCoor(lookAtX-naturalDistance))>width/2){dupliDirect = -dupliDirect;}
    if(loopCoor(scrollX-naturalDistance)> -naturalDistance)dupliDirect = -dupliDirect;

    translate(width/2,height);
    //scale(1.0/scale);
    if(drawLighter)scale(0.5);
    //translate(width+100,0);
    translate(-width/2,-height);


    //境目が見えるとき、境目が見える方向に同じものを複製して描画する
    translate(-scrollX,-scrollY);
    //背景
    image(background, 0, 0);
    translate(dupliDirect * stageWidth,0);
    image(background, 0, 0);
    translate(-dupliDirect* stageWidth,0);
    //HPバーの表示
    translate(scrollX,scrollY);
    noStroke();
    float HPration = (float)player[0].hp/player[0].MAX_HP;
    fill(0,0,0,200);
    rect(20,20,264,19);
    fill(40,0,0);
    rect(22,22,260,15);
    fill(200,230,10);
    rect(22+260*(1.0-HPration),22,260*HPration,15);
    HPration = (float)player[1].hp/player[1].MAX_HP;
    fill(0,0,0,200);
    rect(width-20-264,20,264,19);
    fill(40,0,0);
    rect(width-22-260,22,260,15);
    fill(200,230,10);
    rect(width-22-260,22,260*HPration,15);
    translate(-scrollX,-scrollY);
    //キャラクター
    player[0].display(0,0);
    player[1].display(0,0);
    translate(dupliDirect * stageWidth,0);
    player[0].display(0,0);
    player[1].display(0,0);
    translate(-dupliDirect* stageWidth,0);
    //当たり判定（デバッグ用）
    for(Collider collider :colliderList){
      collider.display();
    }
    translate(dupliDirect * stageWidth,0);
    for(Collider collider :colliderList){
      collider.display();
    }
    translate(-dupliDirect* stageWidth,0);
    //エフェクトの表示
    effectsHolder.display();
    translate(dupliDirect * stageWidth,0);
    effectsHolder.display();
    translate(-dupliDirect* stageWidth,0);
    translate(scrollX,scrollY);
    fill(255);
    //if(abs(loopCoor(scrollX-naturalDistance)-loopCoor(lookAtX-naturalDistance))>width/2){}//stop();}
    translate(width/2,height);
    if(drawLighter)scale(2);
    translate(-width/2,-height);
    if(NConnect!=null)text("frameRate" + NConnect.frameRate, 0, 20);
    else text("frameRate" + frameRate, 0, 20);
    text(
    //"loopCoor(scrollX-naturalDistance):"+loopCoor(scrollX-naturalDistance) + "\n" +
    //"loopCoor(lookAtX-naturalDistance):"+loopCoor(lookAtX-naturalDistance) +
    "\nThis:" + keyStateThis + ", Oppo:" + keyStateOppo +
    //"\nscrollY:"+scrollY +
    //"\np[0]stateBufCount:"+player[0].stateBufCount+
    "\n", 0, 30);
    translate(scrollX,scrollY);
  }


  /*player内部から呼び出すための関数、ふつうthisを引数にとる
  呼び出すplayerに対して攻撃可能性があるColliderを判定し、ダメージ処理など*/
  int collisionalDetect(Player targetPlayer){
    if(colliderList==null)return -1;
    for(Collider activeCollider : colliderList){
      if(activeCollider.parent==targetPlayer)continue;//自分以外が発したcolliderで(発動したひとが自分自身のものを除く
      if(activeCollider.attackable==false)continue;//攻撃することができて         (攻撃可能性がないものを除く
      if(activeCollider.attackedList.indexOf(targetPlayer.collider)!=-1)continue;//攻撃済リストに含まれない
      if(!targetPlayer.collider.colliding(activeCollider))continue;//自分自身と接している (接していないものを除く
      //ここで利用できるcolliderList.get(i)はすべて呼び出し側の
      //targetPlayerに対して命令を渡す
      //プレイヤーにダメージ
      targetPlayer.getDamage(activeCollider);
      //判定の攻撃済リストについか
      activeCollider.attackedList.add(targetPlayer.collider);
      println("damaged");
    }
    return 1;
  }
  //あるプレイヤーに対して攻撃する判定が指定した当たり判定の中に存在するかを正否で返す
  boolean collisionalDetect(Player targetPlayer, Collider explorationCollider){
    if(colliderList==null)return false;
    for(Collider activeCollider : colliderList){
      if(activeCollider.parent==targetPlayer)continue;//自分以外が発したcolliderで(発動したひとが自分自身のものを除く
      if(activeCollider.attackable==false)continue;//攻撃することができて         (攻撃可能性がないものを除く
      if(activeCollider.attackedList.indexOf(targetPlayer.collider)!=-1)continue;//攻撃済リストに含まれない
      if(explorationCollider.colliding(activeCollider))return true;//探査用Colliderと接しているとき、trueを返す
    }
    return false;
  }

  //未使用
  //当たり判定同士での相殺などについて書くつもりだった
  void colliderOffset(){
    for(Collider passiveCollider : colliderList){
      if(passiveCollider.damageable==false)continue;//被ダメージ可能性があるものすべてについてのみ、
      for(Collider activeCollider : colliderList){
        if(passiveCollider==activeCollider)continue;
        if(passiveCollider.parent == activeCollider.parent)
          continue;//自分以外が発したcolliderで(それの親となるplayerが同一のものを除く
        if(activeCollider.attackable==false)continue;//攻撃することができて    (攻撃可能性がないものを除く
        if(activeCollider.attackedList.indexOf(passiveCollider)!=-1)continue;//攻撃済リストに含まれない
        if(!passiveCollider.colliding(activeCollider))continue;//自分自身と接している (接していないものを除く
        //ここで利用できるactiveColliderはすべて呼び出し側の
        //Collision型 passiveColliderに対して命令を渡す
        activeCollider.attackedList.add(passiveCollider);
        //activeCollider.corruption();
      }
    }
  }

  //指定判定を消す
  void destroyCollider(Collider collider){
    colliderList.remove(collider);
  }

  //地上の当たり判定
  void EndPointCollision(Player p){
    p.x = (p.x+stageWidth)%stageWidth;
    if(p.y<-stageHeight+height){p.y = -stageHeight+height;p.vy=0.3*-p.vy;}
    //p.isGroundingは空中にいるとき0
    //着地した瞬間に1
    //それ以外の着地した状態が2となるようにする
    if(p.y>horizon-p.hig){
      if(p.isGrounding==0)p.isGrounding=1;
      else p.isGrounding=2;
      p.y = horizon-p.hig;
    }
    else p.isGrounding=0;
  }

  void stop(){
    if(NConnect!=null)NConnect.stop();
  }

  float loopCoor(float num){return (num+stageWidth)%stageWidth;}

}




//ネットワーク通信をおこなうやつ
abstract class NetworkConnector{
  int syncCount;
  String scrap;
  LinkedList<String> queuedData = new LinkedList<String>();
  final int SYNC_LIMIT = 50;
  String writeStr;

  float frameRate;
  int preMillis;

  //進行具合をカウントで指定しておいて処理が進みすぎたほうを強制的に停止させる。
  //そのための同期処理を行う関数、nullを返すとそのループでの処理を停止する
  String toSyncBuffer(){
    fill(255);
    //相手となるserver,clientが認識できないとき
    if(!isActive()){text("相手を待っています...",0,10);return null;}
    //無限に送られてくるデータをとりあえず'\n'で分割してキューに入れ続ける
    scrap += readStr();
    fill(0,200);
    rect(0,100,180,50);
    fill(0,255,0,200);
    if(scrap!=null)
    while(scrap.indexOf('\n')!=-1){
      queuedData.add(scrap.substring(0,scrap.indexOf('\n')));
      scrap = scrap.substring(scrap.indexOf('\n')+1,scrap.length());
    }
    //現状の伝達
    write("" + syncCount + "_" + writeStr + "\n");
    //syncCountが一致するまで送られてきたデータすべてについて照合を行う
    writeStr = "";
    //queueの中にデータがある場合、
    while(true){
      if(queuedData.isEmpty())break;//queueがなくなったら終了
      String[] buf = queuedData.remove(0).split("_");//deq
      if(buf.length<1)continue;
      text("\nbuf[0]:syncCount = "+buf[0]+":"+syncCount+
      "",0,120);
      //syncCountが小さいほうが処理を行う
      if((int(buf[0]+1)+int(buf[0])+SYNC_LIMIT/2)%SYNC_LIMIT>=(syncCount+int(buf[0]+1)+SYNC_LIMIT/2)%SYNC_LIMIT){
        syncCount = (syncCount+1)%SYNC_LIMIT;
        //frameRateの算出
        if (syncCount==1){
          this.frameRate = 1000.0/((float)(millis()-preMillis)/SYNC_LIMIT);
          preMillis = millis();
        }
        //print(buf[1]);
        //同じ文字列が重複することがあるため、それを取り除く
        buf[1] = strShorten(buf[1]);
        //println(" to " + buf[1]);
        return  buf[1];
      }
    }
    return null;
  }

  //次に送信するデータを初期化
  void writeLine(String line){
    writeStr = line + writeStr;
  }
  //次に送信するデータの後ろに追加
  void addLine(String line){
    writeStr += "," + line;
  }

  //Server,Clientクラスにある汎用的な処理をオーバーライドしておく
  abstract void stop();
  abstract void write(int num);
  abstract void write(String str);
  abstract String readStr();
  abstract int readNum();
  abstract boolean isActive();
}

//サーバー
class ServerControler extends NetworkConnector{
  Server myServer;
  ServerControler(PApplet parent, int port){
    myServer = new Server(parent, port);
    println("asServer");
  }

  public void write(int num){myServer.write(num);}
  public void write(String str){myServer.write(str);}
  public String readStr(){
    Client nextClient = myServer.available();
    return nextClient.readString();
  }
  public int readNum(){
    Client nextClient = myServer.available();
    return nextClient.read();
  }
  public boolean isActive(){
    Client nextClient = myServer.available();
    if(nextClient != null)return true;
    return false;}

  public void stop(){
    myServer.stop();
  }
}
//クライアント
class ClientControler extends NetworkConnector{
  Client myClient;
  ClientControler(PApplet parent, int port){
    myClient = new Client(parent, "none" , port);
    println("asClient");
  }
  ClientControler(PApplet parent, String IPAddress, int port){
    myClient = new Client(parent, IPAddress , port);
    println("asClient");
  }

  public void write(int num){myClient.write(num);}
  public void write(String str){myClient.write(str);}
  public String readStr(){
    return myClient.readString();
  }
  public int readNum(){
    return myClient.read();
  }
  public boolean isActive(){
    if(myClient.active())return true;
    return false;
  }

  public void stop(){
    myClient.stop();
    print("closed");
  }
}


//入力されているコマンドをリストで管理
class Command{
  final static int limit = 40;
  LinkedList<Integer> keyQueue = new LinkedList<Integer>();
  LinkedList<Integer> limitList = new LinkedList<Integer>();
  int masterCount;
  Command(){
  }

  void update(int[] keyState){
    //リストの要素が0→1になる瞬間にmastercountを起動、
    //以下、リストの要素が0にならない限りインクリメントし続けるのに対して、
    //追加されたキーがリストに保存されている上限値を現状のmasterCount+limitとする
    //矢印キーの挙動をキューに入れる
    for(int i = 0; i < 4; i++){
      if(keyState[i]==1){
        keyQueue.add(i);
        limitList.add(masterCount+limit);
      }
    }

    //既定の時間制限からはずれたものはリストから除去
    if(!limitList.isEmpty()){
      while(masterCount==limitList.get(0)){
        keyQueue.remove(0);
        limitList.remove(0);
        if(limitList.isEmpty())break;
      }
      masterCount++;
      if(limitList.isEmpty())masterCount=0;
    }
  }

  //現在のキーを配列のオブジェクトとして提供する
  Integer[] now(){
    return keyQueue.toArray(new Integer[0]);
  }

}

//計6キーの情報をバイナリでやってくれるやつ
class NowKey{
  int z,x,Ri,Do,Le,Up;
  NowKey(){
    z=x=Ri=Do=Le=Up=0;
  }
  int returnBynary(){
    return z*16 + x*32 + Ri*1 + Do*2 + Le*4 + Up*8;
  }
}
//入力との対応付け
void keyPressed() {
  //使用するキーが押されたら、対応する変数を1に
  switch(key) {
    case 'z':nowKey.z = 1;break;
    case 'x':nowKey.x = 1;break;
  }
  switch(keyCode) {
    case RIGHT:nowKey.Ri =1;break;
    case DOWN: nowKey.Do =1;break;
    case LEFT: nowKey.Le =1;break;
    case UP:   nowKey.Up =1;break;
    case SHIFT: drawLighter=!drawLighter;break;
  }
  keyStateThis = nowKey.returnBynary();
}

void keyReleased() {
  //使用するキーが離されたら、対応する変数をfalseに
  switch(key) {
    case 'z':nowKey.z = 0;break;
    case 'x':nowKey.x = 0;break;
  }
  switch(keyCode) {
    case RIGHT:nowKey.Ri =0;break;
    case DOWN: nowKey.Do =0;break;
    case LEFT: nowKey.Le =0;break;
    case UP:   nowKey.Up =0;break;
  }
  keyStateThis = nowKey.returnBynary();
}

//トレーニング用、インターネットで同期しないStage
class TrainingRoom extends Stage{
  //相手プレイヤーをbotとしてこのリストに従って操作する
  int[] botKeyRecipe = {4,  4, 4, 0, 1, 2, 4, 2, 1, 0, 4, 3, 5 , 5};
  int[] botDelayRecipe={100,40,80,4, 4, 4, 60,4, 4, 4, 80,60,60,130};
  int keyCount = 0;
  int delayCount = 0;

  TrainingRoom(PApplet applet_, Player p0, Player p1){
    super(applet_, null, p0, p1);
  }

  void update(){
    //選択画面への復帰
    if(keyCode==TAB){changeScene(new CharaChoiceforTraining(parent));return;}

    //botの操作
    keyStateOppo=0;
    delayCount++;
    if(delayCount==botDelayRecipe[keyCount]){
      keyCount = (keyCount+1)%botDelayRecipe.length;
      keyStateOppo = (int)pow(2, botKeyRecipe[keyCount]);
      delayCount=0;
    }
    super.update();
    text("TABキーでもどれます\nSHIFTキーで描画軽く",0,height-20);
  }
}
//インターネットで同期しないCharaChoice
class CharaChoiceforTraining extends CharaChoice{
  CharaChoiceforTraining(PApplet parent_){
    super(parent_, null);
  }
  CharaChoiceforTraining(PApplet parent_, int[] keyState_){
    super(parent_, null, keyState_);
  }

  void update(){
    otCursorSelected = true;
    //相手のカーソルをbotとして操作する
    if(frameCount%70==0)otCursor = (otCursor + 1 + cursorLimit)%cursorLimit;
    super.update();
  }

  void toStage(){
    Player p0buf, p1buf;
    println(myCursor);
    switch(myCursor) {
    case 0:p0buf = new LisaPlayer();break;
    case 1:p0buf = new SotaiPlayer();break;
    case 2:p0buf = new AdelePlayer();break;
    case 3:p0buf = new ChinaGirlPlayer();break;

      //change

      // case 2:p0buf = new _キャラ名_Player();break;

    default:p0buf = new PlainPlayer();break;
    }
    switch(otCursor) {
    case 0:p1buf = new LisaPlayer();break;
    case 1:p1buf = new SotaiPlayer();break;
    case 2:p1buf = new AdelePlayer();break;
    case 3:p1buf = new ChinaGirlPlayer();break;

      // case 2:p1buf = new _キャラ名_Player();break;

    default:p1buf = new PlainPlayer();break;
    }
    changeScene(new TrainingRoom(parent,p0buf, p1buf));
  }
}