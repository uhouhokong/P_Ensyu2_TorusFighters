int Trig = 9;
int Echo = 8;
int Duration;
int Distance;
int count;

void setup() {
  Serial.begin(9600);
}

void loop() {
  digitalWrite(Trig, LOW);
  delayMicroseconds(1);
  digitalWrite(Trig, HIGH);
  delayMicroseconds(11);
  digitalWrite(Trig, LOW);
  Duration = pulseIn(Echo, HIGH);
  if (Duration > 0) {
    Distance = (float)Duration / 2 * 340 * 100 / 1000000;//cmに変換
    if (Distance > 1) {
      Serial.write(Distance/4);//processingと通信
      count=0;
    } else {
      count++;
    }
    if (count >= 6) {//距離が遠すぎると1以下になることに対応
      Serial.write(Distance/4);
      count = 0;
    }
  }
}
