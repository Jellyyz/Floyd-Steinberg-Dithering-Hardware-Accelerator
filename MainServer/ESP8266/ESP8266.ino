#include <ESP8266WiFi.h>
#include <WiFiClient.h>

const char* SSID = "ARRIS-78CD";
const char* PASS = "5G2445301944";
const uint16_t port = 8585;
const char* host = "192.168.0.21";
WiFiClient client;

void setup() {
  Serial.begin(115200);         // Start the Serial communication to send messages to the computer
  delay(10);
  Serial.println('\n');
  
  WiFi.begin(SSID, PASS);             // Connect to the network
  Serial.print("Connecting to ");
  Serial.print(SSID);
  Serial.println(" ...");

  int i = 0;
  while (WiFi.status() != WL_CONNECTED) { // Wait for the Wi-Fi to connect
    delay(1000);
    Serial.print(++i); 
    Serial.print(' ');
  }

  Serial.println('\n');
  Serial.println("Connection to WiFi established!");  
  Serial.print("IP address:\t");
  Serial.println(WiFi.localIP());         // Send the IP address of the ESP8266 to the computer
}

void loop() {
  // put your main code here, to run repeatedly:
  if (!client.connect(host, port))
  {
      Serial.println("Connection to server failed, retrying...");
      delay(1000);
      return;
  }

  Serial.println("Connected to server!");

  delay(250);
  int i = 0;
  while (client.available()>0)
  {
    char ch = static_cast<char>(client.read());
    Serial.print(ch);
    Serial.print("\n");
    i++;
  }
  Serial.println(i);

  Serial.print("\n");
  client.stop();
  delay(1000);
}
