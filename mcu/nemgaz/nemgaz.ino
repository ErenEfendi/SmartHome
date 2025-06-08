#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>

#include <WiFi.h>
#include <FirebaseESP32.h>
#include <Arduino.h>
#include <ESP32Servo.h>

// Wi-Fi bilgileri
#define WIFI_SSID ""
#define WIFI_PASSWORD ""

// Firebase bilgileri
#define FIREBASE_HOST ""
#define FIREBASE_AUTH ""

// === DHT11 ===
#define DHTTYPE DHT11
#define DHT1_PIN 21
#define DHT2_PIN 5
#define DHT3_PIN 4

DHT dht1(DHT1_PIN, DHTTYPE);
DHT dht2(DHT2_PIN, DHTTYPE);
DHT dht3(DHT3_PIN, DHTTYPE);

// === MQ-2 ve Buzzer ===
#define MQ2_PIN 34         // Analog giriş
#define BUZZER_PIN 33
#define GAS_THRESHOLD 720

// === Firebase Nesneleri ===
FirebaseData firebaseData;
FirebaseConfig firebaseConfig;
FirebaseAuth firebaseAuth;

void setup() {
  Serial.begin(115200);

  // DHT başlat
  Serial.println("DHT11 sensörleri başlatılıyor...");
  dht1.begin();
  dht2.begin();
  dht3.begin();

  // Buzzer
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);

  // Wi-Fi bağlantısı
  Serial.println("Wi-Fi'ye bağlanılıyor...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWi-Fi bağlantısı başarılı.");

  // Firebase başlat
  firebaseConfig.host = FIREBASE_HOST;
  firebaseConfig.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&firebaseConfig, &firebaseAuth);
  Firebase.reconnectWiFi(true);
  Serial.println("Firebase bağlantısı başarılı.");

  Serial.println("MQ-2 ve buzzer hazır.");
}

void loop() {
  delay(10000);  // 15 saniyede bir veri oku

  // === DHT11 Değerleri ===
  float temp1 = dht1.readTemperature();
  float hum1 = dht1.readHumidity();

  float temp2 = dht2.readTemperature();
  float hum2 = dht2.readHumidity();

  float temp3 = dht3.readTemperature();
  float hum3 = dht3.readHumidity();

  Serial.println("---- DHT11 Değerleri ----");

  if (!isnan(temp1)) {
    Firebase.setFloat(firebaseData, "/SmartHome/monitoring/temperature1", temp1);
    Serial.print("Temp1: "); Serial.println(temp1);
  }
  if (!isnan(temp2)) {
    Firebase.setFloat(firebaseData, "/SmartHome/monitoring/temperature2", temp2);
    Serial.print("Temp2: "); Serial.println(temp2);
  }
  if (!isnan(temp3)) {
    Firebase.setFloat(firebaseData, "/SmartHome/monitoring/temperature3", temp3);
    Serial.print("Temp3: "); Serial.println(temp3);
  }

  if (!isnan(hum1)) {
    Firebase.setFloat(firebaseData, "/SmartHome/monitoring/humidityLevel1", hum1);
    Serial.print("Hum1: "); Serial.println(hum1);
  }
  if (!isnan(hum2)) {
    Firebase.setFloat(firebaseData, "/SmartHome/monitoring/humidityLevel2", hum2);
    Serial.print("Hum2: "); Serial.println(hum2);
  }
  if (!isnan(hum3)) {
    Firebase.setFloat(firebaseData, "/SmartHome/monitoring/humidityLevel3", hum3);
    Serial.print("Hum3: "); Serial.println(hum3);
  }

  // === MQ-2 Gaz Okuma ===
  int gasValue = analogRead(MQ2_PIN);  // 0–4095 arası
  Serial.print("MQ-2 Gaz Seviyesi: ");
  Serial.println(gasValue);

  // Firebase'e gaz seviyesi gönder
  Firebase.setInt(firebaseData, "/SmartHome/monitoring/gasLevel", gasValue);

  // Buzzer kontrol
  if (gasValue > GAS_THRESHOLD) {
    digitalWrite(BUZZER_PIN, HIGH);
    Serial.println("⚠️ Gaz seviyesi yüksek! Buzzer aktif.");
  } else {
    digitalWrite(BUZZER_PIN, LOW);
    Serial.println("✅ Gaz seviyesi normal.");
  }

  Serial.println("-------------------------\n");
}
