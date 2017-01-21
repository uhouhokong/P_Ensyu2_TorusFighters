//担当:下川,鈴木
//Sceneクラス、Titleクラス、CharaChoiceクラス、Objectクラスについて実装

class Scene {
  PApplet parent;
  int keyState [] = new int[6];
  void startUp() {
  }
  void update() {
  }
  void stop() {
  }
  void inputKey( int keyState_ ) {      //キー入力
    if (( keyState_&1 ) ==1)  keyState[0]++; 
    else keyState[0] = 0;
    if (( keyState_&2) ==2)  keyState[1]++; 
    else keyState[1] = 0;
    if (( keyState_&4 ) ==4)  keyState[2]++; 
    else keyState[2] = 0;
    if (( keyState_&8 )==8)  keyState[3]++; 
    else keyState[3] = 0;
    if (( keyState_&16 )==16) keyState[4]++; 
    else keyState[4] = 0;
    if (( keyState_&32 )==32) keyState[5]++; 
    else keyState[5] = 0;
  }
}

class Title extends Scene {      //タイトル画面のクラス
  int cursor = 0;
  int cursorLimit = 3;
  String[] menus = { "AsServer", "AsClient", "TrainingRoom" };
  PImage logo;

  Title() {
  }
  Title( PApplet parent_ ) {
    parent = parent_;
    logo = loadImage ( "logo.png" );
  }
  Title( PApplet parent_, int[] keyState_ ) {
    parent = parent_; 
    keyState = keyState_;
    logo = loadImage ( "logo.png" );
  }
  void startUp() {
  }

  void update() {
    inputKey( keyStateThis );
    if ( keyState[0]==1 )cursor = ( cursor + 1+cursorLimit ) % cursorLimit;      //右キーを押したら右へ
    if ( keyState[2]==1 )cursor = ( cursor - 1+cursorLimit ) % cursorLimit;      //左キーを押したら左へ

    if ( keyState[4]==1 ) {
      switch( cursor ) {
      case 0:
        changeScene( new CharaChoice( parent, new ServerControler( parent, 8010 ), keyState )); 
        break;
      case 1:
        changeScene( new CharaChoice( parent, new ClientControler( parent, serverIP, 8010 ), keyState ));
        break;
      case 2:
        changeScene( new CharaChoiceforTraining( parent, keyState ));
        break;
      }
      stop();
      return;
    }
    display();
  }


  void display() {
    background( 0 );
    
    image ( logo, width/2-300, height/2-250, 600, 500 );
    fill ( 255, 0, 0 );
    text( menus[0], width*2/10+15, height*14/15-5 );
    text( menus[1], width*5/10-15, height*14/15-5 );
    text( menus[2], width*7/10+25, height*14/15-5 );
    
    ellipse( width*( 4+cursor*3.6 )/14-50, height*14/15-10, 10, 10 );
  }
  void stop() {
  }
}

class CharaChoice extends Scene {      //キャラクター選択画面のクラス

  int playerNo;
  int myCursor = 0;
  boolean myCursorSelected = false;
  int otCursor = 0;
  boolean otCursorSelected = false;
  int cursorLimit = 4;
  String[] menus = { "Lisa", "Sotai", "Adele", "China Girl" };
  PImage icon1, icon2, icon3, icon4, vs, icon1_, icon2_, icon3_, icon4_, flame;
  PImage icon1ex, icon2ex, icon3ex, icon4ex, icon1_ex, icon2_ex, icon3_ex, icon4_ex;
  int gray1 = 150;
  int gray2 = 150;  
  int gray3 = 150;  
  int gray4 = 150;
  int gray5 = 150;
  int gray6 = 150;  
  int gray7 = 150;  
  int gray8 = 150;


  NetworkConnector NConnect;

  CharaChoice() {
  }
  CharaChoice( PApplet parent_, NetworkConnector NConnect_ ) {
    parent = parent_;
    NConnect = NConnect_;
    if ( NConnect instanceof ServerControler )playerNo = 0;
    else playerNo = 1;
    nowKey = new NowKey();
    inputImg();
  }
  CharaChoice( PApplet parent_, NetworkConnector NConnect_, int[] keyState_ ) {
    keyState = keyState_;
    parent = parent_;
    NConnect = NConnect_;
    if ( NConnect instanceof ServerControler )playerNo = 0;
    else playerNo = 1;
    nowKey = new NowKey();
    inputImg();
  }
  void startUp() {
  }

  void update() {
    inputKey(keyStateThis);      //キー情報の更新

    if ( !myCursorSelected ) {
      if ( keyState[1]==1 ) myCursor = ( myCursor + 1 + cursorLimit ) % cursorLimit;
      if ( keyState[3]==1 ) myCursor = ( myCursor - 1 + cursorLimit ) % cursorLimit;
    }

    if ( keyState[4]==1 ) {
      myCursorSelected = true;
    }
    if ( keyState[5]==1 ) {
      if ( myCursorSelected ||  otCursorSelected ) {
        myCursorSelected = false;
      } else {
        changeScene( new Title( parent, keyState ));
        NConnect.stop();
        return;
      }
    }

    if ( NConnect!=null ) if ( !syncData() ) return;

    if ( myCursorSelected && otCursorSelected ) {
      toStage();
      if ( NConnect!=null ) NConnect.addLine( "0,"+otCursor+","+myCursor );
      return;
    }


    display();
  }
  
  void inputImg(){
    icon1 = loadImage( "Lisa.png" );     //アイコン
    icon1_ = loadImage( "Lisa_.png" );    //表示画像
    icon2 = loadImage( "sotaikun.png" );
    icon2_ = loadImage( "sotaikun_.png" );
    icon3 = loadImage( "Adele.jpg" );
    icon3_ = loadImage( "Adele_.png" );
    icon4 = loadImage( "chinagirl.png" );
    icon4_ = loadImage( "chinagirl_.png" );

    icon1ex = loadImage( "Lisaex.png" );     //反転アイコン
    icon1_ex = loadImage( "Lisa_ex.png" );    //反転表示画像
    icon2ex = loadImage( "sotaikunex.png" );
    icon2_ex = loadImage( "sotaikun_ex.png" );
    icon3ex = loadImage( "Adeleex.jpeg" );
    icon3_ex = loadImage( "Adele_ex.png" );
    icon4ex = loadImage( "chinagirlex.png" );
    icon4_ex = loadImage( "chinagirl_ex.png" );
    flame = loadImage ( "flame.png" );
    vs = loadImage( "vs.png" );
  }
  
  void display() {
    background( 0 );
    fill( 255 );
    text( "choose your charactor", 50, 30 );

    text( menus[0], width*0/5+10, height*2/15-10 );
    text( menus[1], width*0/5+10, height*5/15+2 );
    text( menus[2], width*0/5+10, height*8/15+14 );
    text( menus[3], width*0/5+10, height*11/15+28 );

    text( menus[0], width*5/5-90, height*2/15-10 );
    text( menus[1], width*5/5-90, height*5/15+2 );
    text( menus[2], width*5/5-90, height*8/15+14 );
    text( menus[3], width*5/5-90, height*11/15+28 );


    fill( 255*playerNo, 0, 255*( 1-playerNo ));               //自分
    if ( myCursorSelected ) fill( 150*playerNo, 0, 150*( 1-playerNo ));
    rect( width*0/5+5, height*( 1+myCursor*2 )/8-10 * myCursor-5, 90, 90 );

    fill( 255*( 1-playerNo ), 0, 255*playerNo );               //相手
    if ( otCursorSelected ) fill( 150*( 1-playerNo ), 0, 150*playerNo );
    rect( width*5/5-95, height*( 1+otCursor*2 )/8-10 * otCursor-5, 90, 90 );

    if ( myCursor == 0  ) {      //選択中のアイコンが光り、大きく表示する
      gray1 = 240;
      gray2 = 150;
      gray3 = 150;
      gray4 = 150;
      image ( icon1_, width*1/5-110, height/2-200, 400, 400 );
    }  
    if ( myCursor == 1 ) {
      gray2 = 240;
      gray1 = 150;
      gray3 = 150;
      gray4 = 150;
      image ( icon2_, width*1/5-130, height/2-200, 400, 400 );
    }  
    if ( myCursor == 2 ) {
      gray3 = 240;
      gray1 = 150;
      gray2 = 150;
      gray4 = 150;
      image ( icon3_, width*1/5-130, height/2-200, 400, 400 );
    }  
    if ( myCursor == 3 ) {
      gray4 = 240;
      gray1 = 150;
      gray2 = 150;
      gray3 = 150;
      image ( icon4_, width*1/5-130, height/2-200, 400, 400 );
    } 
    if ( otCursor == 0  ) {
      gray5 = 240;
      gray6 = 150;
      gray7 = 150;
      gray8 = 150;
      image ( icon1_ex, width*3/5-130, height/2-200, 400, 400 );
    }  
    if ( otCursor == 1 ) {
      gray6 = 240;
      gray5 = 150;
      gray7 = 150;
      gray8 = 150;
      image ( icon2_ex, width*3/5-130, height/2-200, 400, 400 );
    }  
    if ( otCursor == 2) {
      gray7 = 240;
      gray5 = 150;
      gray6 = 150;
      gray8 = 150;
      image ( icon3_ex, width*3/5-130, height/2-200, 400, 400 );
    }  
    if ( otCursor == 3 ) {
      gray8 = 240;
      gray5 = 150;
      gray6 = 150;
      gray7 = 150;
      image ( icon4_ex, width*3/5-130, height/2-200, 400, 400 );
    } 

    tint ( gray1 );
    image( icon1, width*0/5+10, 60, 80, 80 );
    tint ( gray5 );
    image( icon1ex, width*5/5-90, 60, 80, 80 );

    tint ( gray2 );
    image( icon2, width*0/5+10, 170, 80, 80 );
    tint ( gray6 );
    image( icon2ex, width*5/5-90, 170, 80, 80 );

    tint ( gray3 );
    image( icon3, width*0/5+10, 280, 80, 80 );
    tint ( gray7 );
    image( icon3ex, width*5/5-90, 280, 80, 80 ); 

    tint ( gray4 );
    image( icon4, width*0/5+10, 390, 80, 80 );
    tint ( gray8 );
    image( icon4ex, width*5/5-90, 390, 80, 80 );
    
    tint ( 255 );
    image ( flame, width/2-80, height/2+20, 200, 200 );
    
    tint ( 255 );
    image ( vs, width/2-50, height/2+70, 100, 100 );
  }
  void stop() {
    NConnect.stop();
  }

  void toStage() {      //キャラ決定後ステージ画面へ
    Player p0buf, p1buf;
    switch( myCursor ) {      //自分のカーソル
    case 0:
      p0buf = new LisaPlayer();
      break;
    case 1:
      p0buf = new SotaiPlayer();
      break; 
    case 2:
      p0buf = new AdelePlayer();         
      break; 
    case 3:
      p0buf = new ChinaGirlPlayer();         
      break; 

    default:
      p0buf = new PlainPlayer();
      break;
    }
    switch( otCursor ) {      //相手のカーソル
    case 0:
      p1buf = new LisaPlayer();
      break;
    case 1:
      p1buf = new SotaiPlayer();
      break;
    case 2:
      p1buf = new AdelePlayer();         
      break; 
    case 3:
      p1buf = new ChinaGirlPlayer();         
      break; 

    default:
      p1buf = new PlainPlayer();
      break;
    }
    changeScene( new Stage( parent, NConnect, p0buf, p1buf ));
  }

  boolean syncData() {
    //次ループで送信するデータの代入
    String input ;
    if ( myCursorSelected ) input = str( myCursor+64 );
    else input = str( myCursor );
    NConnect.writeLine( input );
    //受信と送信
    String ref = NConnect.toSyncBuffer();
    if ( ref==null ) return false;
    String[] ref_ = ref.split(",");
    //0番目はカーソル同期
    int buf;
    buf = int( ref_[0] );
    if ( buf!=-1 ) {
      otCursor = buf&63;
      if (( buf&64 )==64 )  otCursorSelected = true;
      else otCursorSelected = false;
    }
    //1番目は同期タイプ識別
    if ( ref_.length>1 ) {
      switch( int( ref_[1] )) {
      case 0://片方がシーンを切り替えたとき
        myCursor = int( ref_[2] );
        otCursor = int( ref_[3] );
        toStage();
        println( "aaaaa" );
        return false;
      }
    }
    return  true;
  }
}