//担当:鈴木
//Adeleキャラクターの画像表示枚数指定、画像の読み込み、当たり判定範囲

class AdelePlayer extends Player {      
  int [] frameList ={ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 2, 3, 2 };      //画像描画枚数

  AdelePlayer() {
    state = new AdeleIdolState( this );
    loadImages();
  }


  void loadImages() {
    images = new PImage[2][frameList.length][];
    if ( frameList.length != images[0].length ) {
      println( "dismatching frameList.length:" + frameList.length + " to images[0].length:" + images[0].length );
      int [] er = new int[1];
      er[100] = 0;
    }
    for ( int i = 0; i < images[0].length; i++ ) {
      images[0][i] = new PImage[frameList[i]];
      images[1][i] = new PImage[frameList[i]];
      println( i );
    }
    int cnt = 0;
    for ( int i = 0; i < images[0].length; i++ ) {
      for ( int j = 0; j < images[0][i].length; j++ ) {
        images[0][i][j] = loadImage( "../../image/Adele/" + NumtoString( 3, cnt ) + ".png" );      //左向き
        images[1][i][j] = loadImage( "../../image/Adele_/" + NumtoString( 3, cnt ) + ".png" );     //右向き
        cnt++;
      }
    }
  }
  
  
//キャラクターの当たり判定範囲
  void actPunch() {
    addCollider ( direction*wid*2/3, -hig/3, wid, hig/3, -1 );
  }
  void actKick() {
    addCollider ( direction*wid*19/20, -hig/5, wid, hig/3, -1 );
  }
  void actDurKick() {
    vx = 0;
  }
  void actFlip() {
    direction = -direction;
    addCollider ( direction*( wid/2 ), 0, wid/2, hig, -1 );
  }
  void actJumpKick() {
    addCollider ( direction*wid*2/3, hig*1/4, wid, hig*2/3, -1 );
  }
  void actTripped() {
    addCollider ( direction*wid*2/3, hig*1/5, wid*3/2, hig/1, -1 );
  }
  void actShootBullet() {
    Bullet newBullet =  addBullet ( direction*wid*2/3,  -50, wid*2/3, hig/3, 140, direction*2.5, 0 );
    Effect newEffect = new Effect ( effectsHolder, effectDataArea[0], 
      "hunmmer", new BulletEndlessLoopEffect ( newBullet, newBullet.countLimit ), new Object ( newBullet, newBullet.wid/2, newBullet.hig/2 ));
    newBullet.effect = newEffect;
    effectsHolder.add ( newEffect );
  }
  
  void actShootBullet2() {
    Bullet newBullet1 = addBullet ( direction*wid*2/3, -50, wid*2/3, hig/3, 140, direction*2.5, 0 );
    Bullet newBullet2 = addBullet ( direction*wid*2/3, -50, wid*2/3, hig/3, 140, direction*2.5, 0 );
    Effect newEffect = new Effect ( effectsHolder, effectDataArea[0], 
      "hunmmer", new BulletEndlessLoopEffect ( newBullet1, newBullet2.countLimit ), new Object ( newBullet1, newBullet2.wid/2, newBullet1.hig/2 ));
    newBullet1.effect = newEffect;
    newBullet2.effect = newEffect;
    effectsHolder.add( newEffect );
  }
  
  void beHeld() {
    changeState ( new AdeleBeHeldState( this ));
  }
  void beFree() {
    changeState ( new AdeleLandState( this ));
  }
  void getDamage ( Collider other ) {
    if ( state instanceof LisaCounterWaitState ) {
      if ( other instanceof Bullet ) {
        changeState ( new AdeleCounterBulletState( this,( Bullet )other ));
      }
    }
    else{
      super.getDamage( other );
    }
  }
}