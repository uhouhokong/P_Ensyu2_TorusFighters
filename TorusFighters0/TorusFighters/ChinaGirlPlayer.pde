//担当:下川

class ChinaGirlPlayer extends Player {
  int [] frameList = {//キャラの画像
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 2, 1
  };

  ChinaGirlPlayer() {
    state = new ChinaGirlIdolState(this);
    loadImages();
  }


  void loadImages() {
    images = new PImage[2][frameList.length][];
    if (frameList.length!=images[0].length) {
      println("dismatching frameList.length:"+frameList.length+" to images[0].length:"+images[0].length);
      int[] er = new int[1];
      er[100]=0;
    }
    for (int i = 0; i < images[0].length; i++) {
      images[0][i] = new PImage[frameList[i]];
      images[1][i] = new PImage[frameList[i]];
      println(i);
    }

    int cnt = 0;
    for (int i = 0; i < images[0].length; i++) {
      for (int j = 0; j < images[0][i].length; j++) {
        images[0][i][j] = loadImage("../../image/中国娘/"+ NumtoString(3, cnt) + ".png");
        images[1][i][j] = loadImage("../../image/中国娘_/"+ NumtoString(3, cnt) + ".png");
        cnt++;
      }
    }
  }

 //振る舞いを関数として提供、act[英単語]()の形で

 //当たり判定
  void actPunch() {
    addCollider(direction*wid*4/5, -hig/8, wid/3*2, hig/5, -1);
  }
  void actKick() {
    addCollider(direction*wid*2/3, hig/11, wid/3*2, hig/4, -1);
  }
  void actDurKick() {
    vx=0;
  }
  void actFlip() {
    direction=-direction;
    addCollider(direction*(wid/2), 0, wid/2, hig, -1);
  }
  void actJumpKick() {
    addCollider(direction*wid*2/3, hig/4, wid/3*2, hig/4, -1);
  }
  void actTripped() {
    addCollider(direction*wid*2/3, hig/3, wid/3*2, hig/4, -1);
  }
  void actShootBullet() {
    addBullet(direction*wid*2/3, 0, wid*2/3, hig/3, 140, direction*1.8, 0);

    Bullet newBullet = addBullet(direction*wid*2/3, 0, wid*2/3, hig/3, 140, direction*1.8, 0);
    Effect newEffect = new Effect(effectsHolder, effectDataArea[0], 
    "ball", new BulletEndlessLoopEffect(newBullet, newBullet.countLimit), new Object(newBullet, newBullet.wid/2, newBullet.hig/2));
    newBullet.effect = newEffect;
    effectsHolder.add(newEffect);
  }
  void actDushPunch() {
    addCollider(direction*wid*2/3, -hig/3, wid, hig/3, -1);
  }
  void beHeld() {//全部に実装
    //changeState(new ChinaGirlBeHeldState(this));
  }
  void beFree() {//全部に実装
    changeState(new ChinaGirlLandState(this));
  }
  void getDamage(Collider other) {//全部に実装
    if (state instanceof ChinaGirlCounterWaitState) {
      if (other instanceof Bullet) {
        changeState(new ChinaGirlCounterBulletState(this, (Bullet)other));
      }
    } else {
      super.getDamage(other);
    }
  }
}