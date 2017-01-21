//EffectDataArea,EffectData,EffectsHolder,Effect,EffectBehaviorおよび以下挙動について実装
//担当:森口

//EffectDataArea
//エフェクトの各データをHashMapで保有するひとまとまり。及び付随する関数群。
//どのシーンでも変わらない領域、キャラごと、（ステージごと:未実装）...に変化する動的な領域、
//の数だけインスタンスを生成しておく。
class EffectDataArea {
  HashMap <String,EffectData> effectDataList = new HashMap<String,EffectData>();
  EffectDataArea(String directoryname){
    inputDatafromFile(directoryname);
  }

  //登録したエフェクトのデータをkey指定により呼び出す。
  EffectData get(String keyStr){
    return effectDataList.get(keyStr);
  }

  //ディレクトリ名を指定するとそこに存在するinputlist.csvを勝手に読み込み
  //それに従ったEffectDataを読み込む
  boolean inputDatafromFile(String directoryname){
    String[] data = loadStrings(directoryname + "/inputlist.csv");
    if(data==null)return false;//loadingError:インポート用ファイルが存在しない
    for(int i = 0; i < data.length; i++){
      String[] line = data[i].split(",");

      //画像リストの読み込み
      ArrayList<PImage> imagesbuf = new ArrayList<PImage>();
      int j = 0;
      PImage nextImage = loadImage(directoryname +"/"+ line[0] +"/"+ NumtoString(3, j) + ".png");
      println("try to road \"" +directoryname +"/"+ line[0] +"/"+ NumtoString(3, j) + ".png" + "\"");
      //ファイルで指定されたフォルダ内でありったけのデータ全てをメモリに展開、リストに保持
      while(nextImage!=null){
        imagesbuf.add(nextImage);
        j++;
        nextImage = loadImage(directoryname +"/"+ line[0] +"/"+ NumtoString(3, j) + ".png");
        println("try to road \"" +directoryname +"/"+ line[0] +"/"+ NumtoString(3, j) + ".png" + "\"");
      }
      PImage[] images_ = null;
      if(!imagesbuf.isEmpty())images_ = imagesbuf.toArray(new PImage[0]);

      //振る舞いタイプの読み込み
      int behaviorNum_ = int(line[1]);

      //音声ファイルの読み込み
      ArrayList<String> soundsbuf = new ArrayList<String>();
      for(int k = 2; k < line.length; k++){
        soundsbuf.add(line[k]);
      }
      String[] sounds_ = null;
      if(!soundsbuf.isEmpty())sounds_ = soundsbuf.toArray(new String[0]);

      effectDataList.put(line[0], new EffectData(images_, behaviorNum_, sounds_));
    }
    return true;
  }
}

//エフェクトの各データそのものの変数のまとまり。
class EffectData{
  PImage[] images;//画像
  int behaviorNum;//生成するbehaviorのタイプ(インスタンスをメモリ上にうまくクローンできればよかった)
  String[] sounds;//音声リスト（ないことが多い）
  EffectData(PImage[] images_, int behaviorNum_, String[] sounds_){
    behaviorNum = behaviorNum_;
    images = images_;
    sounds = sounds_;
  }
}


//実働するエフェクトオブジェクト群を保有するひとまとまり。及び付随する関数群
//インスタンスはstageにつき一つずつか
class EffectsHolder{
  LinkedList<Effect> effectsList = new LinkedList<Effect>();

  //全部のアップデート。探索中に要素を削除する可能性があるからイテレータで
  void update(){
    for(Iterator it = effectsList.iterator(); it.hasNext(); ) {
      Effect element = (Effect)it.next();
      if(element.update()) {
        it.remove();
      }
    }
  }
  //表示する
  void display(){
    for(Iterator it = effectsList.iterator(); it.hasNext(); ) {
      Effect element = (Effect)it.next();
      element.display();
    }
  }
  //エフェクトを生成したい時に外部から呼び出す。
  void add(Effect effect){
    effectsList.add(effect);
  }
}

//各々経過時間などの状態変数をもったエフェクトのひとかたまり。
class Effect extends Object{
  EffectsHolder parentHolder;
  EffectData effectData;
  EffectBehavior behavior;//必ず新規のオブジェクトで初期化されなければならない
  AudioPlayer[] audioPlayer;

  //コンストラクタで"どの実働領域に","どこのデータ領域の","何という名前のエフェクトを","どこに"出すかを指定
  Effect(EffectsHolder parentHolder_, EffectDataArea dataArea_, String keyStr, Object object_){
    initialize(parentHolder_, dataArea_, keyStr, null, object_);
  }
  //上のコンストラクタに加え、エフェクトの行動を新しく記述できるように。
  Effect(EffectsHolder parentHolder_, EffectDataArea dataArea_, String keyStr, EffectBehavior behavior_, Object object_){
    initialize(parentHolder_, dataArea_, keyStr, behavior_, object_);
  }

  void initialize(EffectsHolder parentHolder_, EffectDataArea dataArea_, String keyStr, EffectBehavior behavior_, Object object_){
    parentHolder = parentHolder_;
    replace(object_);
    effectData = dataArea_.get(keyStr);
    if(effectData == null){//データがない時はないを返す
      println("Effect\"" + keyStr + "\" may not exist");
      return;
    }
    //audioPlayerの作成
    audioPlayer = null;
    if(effectData.sounds!=null){
      audioPlayer = new AudioPlayer[effectData.sounds.length];
      for(int i=0; i<effectData.sounds.length; i++){
        audioPlayer[i] = minim.loadFile("../../sound/" + effectData.sounds[i]);//ここでハードディスクにつなぐのは頭悪いのであらかじめメモリに展開しておいてクローンとかすればよかった
      }
    }

    if(behavior_==null){//effectDataからbehaviorを引っ張ってくる場合、idに応じたbehaviorのインスタンスを新規に作成する
      switch(effectData.behaviorNum){
        case 0:behavior = new SimplePassingEffect();break;
        case 1:behavior = new EndlessLoopEffect();break;
      }
    }
    else{//behaviorが新規に指定されている場合、新しいオブジェクトをそのまま代入
      behavior = behavior_;
    }
    behavior.setup(this);//behaviorの新しいインスタンスに自分を認識させる
    startUp();
  }

  void startUp(){
    behavior.startUp();
  }

  boolean update(){
    if(behavior!=null)
    return behavior.update();
    return true;
  }
  public void display(){
    PImage sprite = null;
    if(effectData.images!=null) sprite = behavior.drawSprite(effectData.images);
    stroke(255);
    strokeWeight(1);
    fill(200,200,40,170);
    if(sprite!=null){
      image(sprite, asWorld().x-sprite.width/2,asWorld().y-sprite.height/2);
    }
    else {
      int wid = 10;
      int hig = 10;
      rect(asWorld().x-wid/2,asWorld().y-hig/2,wid,hig);
    }
    fill(255,255,255,230);
    if(consoleForDebug){
      text("AAAA:"+ "" + "\n " +
      "",
      asWorld().x,asWorld().y);
    }
  }

  void playSound(int num){
    if(audioPlayer==null)return;
    if(num<0)return;
    if(num>audioPlayer.length-1)return;
    audioPlayer[num].play();
  }

  void generateEffect(){
    parentHolder.add(this);
  }
}

//Strategyパターン。エフェクトの振る舞いを記述するクラスの元締め。
abstract class EffectBehavior{
  Effect effect = null;
  final int defaultFrameRate = 4;
  int frames = 0;//カウントよう変数
  void setup(Effect effect_){
    effect = effect_;
  }
  abstract void startUp();
  abstract boolean update();//trueを返すと消滅する
  abstract PImage drawSprite(PImage[] images);
  //もしものときのメッセージを送る用。詳しい内容は必要なものにそれぞれ記述。
  void message(){}

  PImage loopAnimation(PImage[] images, int fps){
    frames = (frames+1)%(images.length*fps);
    return images[(frames/fps)%images.length];
  }
  PImage straightAnimation(PImage[] images, int fps){
    frames = min((images.length*fps-1),(frames+1));
    return images[(frames/fps)%images.length];
  }
  PImage directionalLoopAnimation(int direction, PImage[] images, int fps){
    frames = (frames+1)%((images.length/2)*fps);
    return images[(frames/fps)%(images.length/2) + images.length/2*direction];
  }
}

//一回表示して消えるもっとも単純なエフェクトの挙動。
class SimplePassingEffect extends EffectBehavior{
  int loops = 0;

  void startUp(){
    effect.playSound(0);
  }

  boolean update(){
    if(loops>0){
      return true;
    }
    frames++;
    return false;
  }
  PImage drawSprite(PImage[] images){
    return straightAnimation(images, defaultFrameRate);
  }
  PImage straightAnimation(PImage[] images, int fps){
    frames = min((images.length*fps-1),(frames+1));
    if(min((images.length*fps-1),(frames+1))==frames)loops++;
    return images[(frames/fps)%images.length];
  }
}
//呼び出してからずっと消えないでしかもループするエフェクトの挙動。
class EndlessLoopEffect extends EffectBehavior{
  int count = 0;
  int limit;
  EndlessLoopEffect(){
    limit = -1;
  }
  //引数に数字をとる場合countで消滅する
  EndlessLoopEffect(int limit_){
    limit = limit_;
  }

  void startUp(){
  }
  boolean update(){
    if(limit!=-1){
      if(count>limit-1)return true;
      count++;
    }
    frames++;
    return false;
  }
  PImage drawSprite(PImage[] images){
    return loopAnimation(images, 10);
  }
}
//弾のスプライトはエフェクトより描画する。
//親となる弾の状態におうじていい感じに画像を切り替えたりしたかったが、
//エフェクト側から呼び出してしまっているのでこれは良くない。
//メッセージ関数を受け取ると消滅エフェクトを新たに生成する。
class BulletEndlessLoopEffect extends EndlessLoopEffect{
  int count = 0;
  int limit;
  Bullet bullet;
  BulletEndlessLoopEffect(Bullet bullet_){
    limit = -1;
    bullet = bullet_;
  }
  BulletEndlessLoopEffect(Bullet bullet_, int limit_){
    limit = limit_;
    bullet = bullet_;
  }

  void startUp(){
  }
  boolean update(){
    if(limit!=-1){
      if(count>limit-1){
        return true;
      }
      count++;
    }
    frames++;
    return false;
  }
  void message(){
    effectsHolder.add(new Effect(effectsHolder, effectDataArea[0],
    "BulletRuptre", effect.asWorld()));
    bullet.terminateReady = true;
    count=limit;
  }
  PImage drawSprite(PImage[] images){
    return directionalLoopAnimation((1-bullet.direction)/2, images, defaultFrameRate);
  }
}