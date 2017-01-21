//担当:大曽根
//arduinoに関するクラス
//パソコンからの距離を取得して離れているかどうかを判定する
import processing.serial.*;

Serial serial;
float inputArduino;


class DistanceSensor {
  int arduinoFlag;
  int arduinoCount;
  int checkCount;
  int resetCount;
  int distance=50;//判定基準
  int checkFlag;
  int resetFlag;
  int value;

  DistanceSensor() {
  }


  void update() {
    //一定回数連続で同じ判定がでた時に変数を変化させる
    if (arduinoFlag>0) {
      //判定基準付近で連続で反応しないように、
      //ある程度近づくまで離れていると判定
      if (inputArduino<distance-15) {
        arduinoFlag=0;
      }
    }

    if (inputArduino>distance) {
      checkCount++;
    }  
    if (inputArduino<=distance) {
      resetCount++;
    }  
    if (checkCount>5) {
      value++;
      if (checkFlag==0) {
        resetCount=0;
        resetFlag=0;
        arduinoFlag++;
      }
      checkFlag++;
    }
    if (resetCount>5&&arduinoFlag==0) {
      value=0;
      if (resetFlag==0) {
        checkCount=0;
        checkFlag=0;
      }
      resetFlag++;
    }
    if (value>0)keyStateThis = 64 + (keyStateThis&63);
    else keyStateThis = 0 + (keyStateThis&63);
  }
}
void mousePressed() {
  keyStateThis = 64 + (keyStateThis&63);//test
}
void mouseReleased() {
  keyStateThis = 0 + (keyStateThis&63);//test
}
void serialEvent(Serial port) {
  inputArduino=port.read();
  inputArduino=inputArduino*4;
}