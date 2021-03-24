
int sensorValue = 0;
int sensorAlto = 50;

void setup() {
  pinMode(12, OUTPUT);
  Serial.begin(115200);

}

void loop() {
  int sensorValue = analogRead(A2);
//  sensorValue = map(sensorValue, 0, 3, 140, 0); 
  delay(200);
  Serial.println(sensorValue);
  delay(100);
  if (sensorValue > sensorAlto) {
    digitalWrite(12, HIGH);
  }
  else {
    digitalWrite(12, LOW);
  }

}
