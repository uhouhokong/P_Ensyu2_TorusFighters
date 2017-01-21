//メインの部分、グローバルな変数に関すること
//担当:森口

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
//センサーの宣言
DistanceSensor sensor;
String serverIP;

import processing.net.*;
//PCのキー入力情報はグローバル領域で管理する
NowKey nowKey = new NowKey();
int keyStateThis;

//エフェクト領域のアドレスをどこからでも参照できるように
EffectDataArea[] effectDataArea = new EffectDataArea[3];
EffectsHolder effectsHolder;
int momentOfClick=0;
Minim minim;
//シーンは1つ
Scene scene;
//描画に関するいくつかのオプション
boolean drawLighter=false;
boolean consoleForDebug = false;
void setup(){
  size(640,480);
  String data[] = loadStrings("../../serverIP.txt");
  serverIP = data[0];
  minim = new Minim(this);
  scene = new Title(this);

  println(Serial.list());
  //***********************************************
  //Arduinoを接続している時に限り以下の行を追加してください
  //
  //serial=new Serial(this, Serial.list()[0], 9600);
  //
  //***********************************************
  sensor=new DistanceSensor();

}

void stop(){
  minim.stop();
  scene.stop();
}

void draw(){frameRate(60);
  momentOfClick=checkMomentOfClick(momentOfClick);
  scene.update();
  sensor.update();
  println(inputArduino);
}

void changeScene(Scene nextScene){
  scene = nextScene;
}

//~~~~~~~~~~~~~~~~~~~~~汎用的な関数群~~~~~~~~~~~~~~~~~~~~~~~~~

//引数の値の符号を返す
int sgn(float num){return (int)(num/abs(num));}

//任意の数字numを空いた桁に"0"を埋めてdigit桁の文字列として返す
String NumtoString(int digit, int num){
  if(((int)pow(10, digit)<num))return null;
  int numDigit=0;
  int i = num/10;
  while(i!=0){
    numDigit++;
    i=i/10;
  }
  String ref="";
  for(int j=0;j<digit-numDigit-1;j++){
    ref += "0";
  }
  ref+=num;
  return ref;
}

//file/folder開くようのエクスプローラーのためのやつ
String openedPathBuffer;
void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    openedPathBuffer = selection.getAbsolutePath();
  }
}

//マウスクリックの瞬間瞬間判定
int checkMomentOfClick(int mOC){
  if(mousePressed){
    if(mOC==-1)return 1;
    else return 0;
  }
  else {
    return -1;
  }
}

//連続した文字列を1つに
String strShorten(String str){
  if(str.length()>1){
    boolean compFlag=true;
    char bufHead = str.charAt(0);
    for(int i=1;i<str.length();i++){
      if(bufHead != str.charAt(i)){
        compFlag=false;
        break;
      }
    }
    if(compFlag){
      str = str(bufHead);
    }
  }
  return str;
}
//重なった文字を一つに
String shortenn(String str){
  for(int i=0;i<str.length()-1;i++){
    char head = str.charAt(i);
    if(head==str.charAt(i+1)){
      str=str.substring(0,i+1)+str.substring(i+2);
    }
  }
  return str;
}