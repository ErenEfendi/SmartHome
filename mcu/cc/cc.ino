#include <WiFi.h>
#include <FirebaseESP32.h>
#include <Arduino.h>
#include <ESP32Servo.h>

#define WIFI_SSID ""
#define WIFI_PASSWORD ""

// Firebase credentials
#define FIREBASE_HOST "" 
#define FIREBASE_AUTH ""

FirebaseData firebaseData;
FirebaseConfig firebaseConfig;
FirebaseAuth firebaseAuth;

// === PIR ve LED ===
#define DOOR_PIR_PIN 32
#define DOOR_LED_PIN 22  // FrontDoor ışığı

#define ROOM_PIR_PIN 19
#define ROOM_LED_PIN 23  // GarageDoor ışığı

unsigned long lastDoorMotionTime = 0;
unsigned long lastRoomMotionTime = 0;
const unsigned long motionHoldTime = 5000;

// === Servo Motorlar ===
#define GARAGE_SERVO_PIN 2
#define MAIN_SERVO_PIN 15
Servo garageServo;
Servo mainServo;
bool garageOpen = false;
bool mainOpen = false;

// === Işıklar (PWM) ===
const int lightPins[] = {25, 26, 27, 14, 12, 13};
const char* firebasePaths[] = {
  "/SmartHome/lights/Toilet/value",
  "/SmartHome/lights/Bedroom/value",
  "/SmartHome/lights/LivingRoom/value",
  "/SmartHome/lights/Garage/value",
  "/SmartHome/lights/Kitchen/value",
  "/SmartHome/lights/Enterance/value"
};

void setup() {
  Serial.begin(115200);

  // PIR & LED pinleri
  pinMode(DOOR_PIR_PIN, INPUT);
  pinMode(ROOM_PIR_PIN, INPUT);
  pinMode(DOOR_LED_PIN, OUTPUT);
  pinMode(ROOM_LED_PIN, OUTPUT);
  digitalWrite(DOOR_LED_PIN, LOW);
  digitalWrite(ROOM_LED_PIN, LOW);

  // PWM ayarları
  for (int i = 0; i < 6; i++) {
    ledcSetup(i, 5000, 8);
    ledcAttachPin(lightPins[i], i);
  }

  // Servo ayarları
  garageServo.setPeriodHertz(50);
  garageServo.attach(GARAGE_SERVO_PIN, 500, 2400);
  mainServo.setPeriodHertz(50);
  mainServo.attach(MAIN_SERVO_PIN, 500, 2400);

  // Wi-Fi
  Serial.println("Wi-Fi bağlanıyor...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWi-Fi bağlı!");

  // Firebase
  firebaseConfig.host = FIREBASE_HOST;
  firebaseConfig.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&firebaseConfig, &firebaseAuth);
  Firebase.reconnectWiFi(true);
  Serial.println("Firebase bağlantısı başarılı.");
}

void loop() {
  unsigned long now = millis();

  // === Kapı PIR ===
  if (digitalRead(DOOR_PIR_PIN) == HIGH) {
    Serial.println("🚪 Kapı hareket algılandı");
    lastDoorMotionTime = now;
    digitalWrite(DOOR_LED_PIN, HIGH);
    Firebase.setInt(firebaseData, "/SmartHome/motionSensor/frontDoor/value", 100);
  }
  if (now - lastDoorMotionTime > motionHoldTime) {
    digitalWrite(DOOR_LED_PIN, LOW);
    Firebase.setInt(firebaseData, "/SmartHome/motionSensor/frontDoor/value", 0);
  }

  // === Oda PIR ===
  if (digitalRead(ROOM_PIR_PIN) == HIGH) {
    Serial.println("🛏️ Oda hareket algılandı");
    lastRoomMotionTime = now;
    digitalWrite(ROOM_LED_PIN, HIGH);
    Firebase.setInt(firebaseData, "/SmartHome/motionSensor/garageDoor/value", 100);
  }
  if (now - lastRoomMotionTime > motionHoldTime) {
    digitalWrite(ROOM_LED_PIN, LOW);
    Firebase.setInt(firebaseData, "/SmartHome/motionSensor/garageDoor/value", 0);
  }

  // === Firebase Işık PWM Kontrolü ===
  for (int i = 0; i < 6; i++) {
    int lightLevel = 0;
    if (Firebase.getInt(firebaseData, firebasePaths[i], &lightLevel)) {
      int pwmValue = map(lightLevel, 0, 100, 0, 255);
      ledcWrite(i, pwmValue);
    } else {
      Serial.printf("Light %d read failed: %s\n", i + 1, firebaseData.errorReason().c_str());
    }
  }

  // === Garage Door Servo ===
  if (Firebase.getBool(firebaseData, "/SmartHome/remoteControl/door/garageDoor")) {
    bool val = firebaseData.boolData();
    if (val && !garageOpen) {
      garageServo.write(90);
      garageOpen = true;
      Serial.println("🚗 Garaj Açıldı");
    } else if (!val && garageOpen) {
      garageServo.write(0);
      garageOpen = false;
      Serial.println("🚗 Garaj Kapandı");
    }
  }

  // === Main Door Servo ===
  if (Firebase.getBool(firebaseData, "/SmartHome/remoteControl/door/mainDoor")) {
    bool val = firebaseData.boolData();
    if (val && !mainOpen) {
      mainServo.write(90);
      mainOpen = true;
      Serial.println("🚪 Ana Kapı Açıldı");
    } else if (!val && mainOpen) {
      mainServo.write(0);
      mainOpen = false;
      Serial.println("🚪 Ana Kapı Kapandı");
    }
  }
  delay(100);
}