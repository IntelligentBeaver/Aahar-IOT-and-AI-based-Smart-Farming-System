#include <WiFi.h>
#include <WebSocketsClient.h>
#include "DHT.h"

// WiFi and WebSocket Server Configuration
const char* ssid = "Galaxy S23 Ultra";
const char* password = "myhome1511";
const char* webSocketServer = "192.168.196.187";  // Replace with your server's IP
const uint16_t port = 3000;

/*
Pin Infos:
1
SENSORS                    PIN NUMBERS

Soil Moisture Sensor    ==   35
IR Sensor               ==   34
Float Sensor            ==   32
Humidity, Temp Sensor   ==   33
Photoresistor Sensor`   ==   39 (connect in series);

Irrigation Pump         ==   12 (put 400ohm resistor in motor or either the motor)

Led  Green              ==   14
Led Blue                ==   27
Led Red                 ==   26

*/
int soilMoisture=0;
int irSensor=0;
int floatSensor=0;
int photoResist=0;

// DHT Sensor ConfigurationHIGH
#define DHTPIN 33  // Pin connected to the DHT sensor
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);


WebSocketsClient webSocket;
unsigned long lastSendTime = 0;           // Timestamp to control sending intervals
const unsigned long sendInterval = 5000;  // Send data every 5 seconds

#define GREEN_BULB_PIN 14
#define RED_BULB_PIN 27
#define BLUE_BULB_PIN 26
#define PHOTO_RESISTOR 39
#define BUZZER_PIN 25
#define GREEN_PUMP_PIN 12

void setup() {
  Serial.begin(115200);
  delay(1000);

  // Initialize DHT Sensor
  dht.begin();

  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi");

  // Initialize WebSocket Client
  webSocket.begin(webSocketServer, port);
  webSocket.onEvent(webSocketEvent);

  pinMode(BUZZER_PIN,OUTPUT);
  digitalWrite(BUZZER_PIN,LOW);
  // Configure the GPIO pin as output
  pinMode(GREEN_BULB_PIN, OUTPUT);
  digitalWrite(GREEN_BULB_PIN, LOW);  // Start with the bulb turned off

  pinMode(RED_BULB_PIN, OUTPUT);
  digitalWrite(RED_BULB_PIN, LOW);  // Start with the bulb turned off

  pinMode(BLUE_BULB_PIN, OUTPUT);
  digitalWrite(BLUE_BULB_PIN, LOW);  // Start with the bulb turned off

  pinMode(GREEN_PUMP_PIN, OUTPUT);
  digitalWrite(GREEN_PUMP_PIN, LOW);

}

void loop() {
  webSocket.loop();  // Keep WebSocket connection alive
  
    // Send data at intervals
    if (millis() - lastSendTime >= sendInterval) {
    lastSendTime = millis();  // Update last send time
    sendSensorData();
  }
}

void sendSensorData() {
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();
  soilMoisture=analogRead(35);
  irSensor = analogRead(34);
  floatSensor = analogRead(32);
  photoResist = analogRead(PHOTO_RESISTOR);


  // Validate sensor readings
  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  // Log data to Serial Monitor
  Serial.print("temperature:");
  Serial.print(temperature);
  Serial.print(" °C, humidity:");
  Serial.print(humidity);
   Serial.print(",soilMoisture:");
  Serial.print(soilMoisture);
   Serial.print(",Ir Sensor:");
  Serial.print(irSensor);
   Serial.print(", Float Sensor : ");
  Serial.print(floatSensor);
  Serial.print(", photoResist: ");
  Serial.print(photoResist);
  Serial.println(" %");
  
  if(photoResist<15){
    digitalWrite(BUZZER_PIN,HIGH);
  }else{
    digitalWrite(BUZZER_PIN,LOW);
  }


  // Create JSON payload
  //String jsonPayload = String("{\"temperature\":" + temperature + ",\"humidity\":" + humidity + "\"Soil Moisture\":" + soilMoisture + "\"Fire Sensor\"" + fir"}" );
String jsonPayload = String("{\"temperature\":" + String(temperature) +
                            ",\"humidity\":" + String(humidity) +
                            ",\"soil_moisture\":" + String(soilMoisture) +
                            ",\"fire_sensor\":" + String(irSensor) +
                            ",\"irrigation\":" + String(floatSensor) +
                             ",\"cattle_sensor\":" + String(photoResist) +
                             "}");

  // Send JSON data via WebSocket
  webSocket.sendTXT(jsonPayload);
}

void webSocketEvent(WStype_t type, uint8_t* payload, size_t length) {
  switch (type) {
    case WStype_CONNECTED:
      Serial.println("Connected to WebSocket server");
      webSocket.sendTXT("{\"message\":\"hello from esp\"}");
      break;

    case WStype_DISCONNECTED:
      Serial.println("Disconnected from WebSocket server");
      break;
    case WStype_TEXT:
      Serial.printf("Received message: %s\n", payload);
      // Parse the received message
      if (strcmp((char*)payload, "led_turn_off") == 0) {
        Serial.println("Turning off the green bulb...");
        digitalWrite(GREEN_BULB_PIN, LOW);    // Turn off the bulb
        //digitalWrite(GREEN_BULB2_PIN, HIGH);  // Turn off the bulb
        digitalWrite(RED_BULB_PIN, LOW);

      } else if (strcmp((char*)payload, "led_turn_on") == 0) {
        Serial.println("Turning on the green bulb...");
        digitalWrite(GREEN_BULB_PIN, HIGH);  // Turn on the bulb
        digitalWrite(RED_BULB_PIN, HIGH); 
        //digitalWrite(GREEN_BULB2_PIN, LOW);  // Turn off the bulb
      }
      if (strcmp((char*)payload, "pump_turn_off") == 0) {
        Serial.println("Turning off the pump...");
        digitalWrite(GREEN_PUMP_PIN, LOW);    // Turn off the bulb
        //digitalWrite(GREEN_BULB2_PIN, HIGH);  // Turn off the bulb

      } else if (strcmp((char*)payload, "pump_turn_on") == 0) {
        Serial.println("Turning on the pump...");
        digitalWrite(GREEN_PUMP_PIN, HIGH);  // Turn on the bulb
        //digitalWrite(GREEN_BULB2_PIN, LOW);  // Turn off the bulb
      }
      break;

    default:
      break;
  }
}
