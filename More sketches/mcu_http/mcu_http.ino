/*
 *  This sketch demonstrates reading GET requests from your local server (request at `actionURL`).
 */
#include "ESP8266WiFi.h"
#include "ESP8266HTTPClient.h"

// Add 2.4 GHz network and password here
const char *SSID = "foo";
const char *SSID_pass = "bar";

const int CONNECTION_LIMIT_INTERVALS = 35;
const int CONNECTION_INTERVAL_TIME = 250;

// Add IPv4 IP address of host
const char *IPv4 = "445.29";
const char *actionURL = "http://172.20.10.2:8000/download/get_image";

//===============================================================================
//  Initialization
//===============================================================================
void setup() {
  pinMode(LED_BUILTIN, OUTPUT);       // Initialize the LED_BUILTIN pin as an output
  digitalWrite(LED_BUILTIN, HIGH);    // Ensure LED is off
  Serial.begin(115200);               // Set comm rate to 115200

  // Set WiFi to station mode and disconnect from an AP if it was previously connected
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  delay(100);

  WiFi.begin(SSID, SSID_pass);

  int intervals = 0;
  while ((WiFi.status() != WL_CONNECTED) && (intervals < CONNECTION_LIMIT_INTERVALS)) {
    intervals++;
    delay(CONNECTION_INTERVAL_TIME);
    Serial.print('.');        
  }

  if (intervals >= CONNECTION_LIMIT_INTERVALS) {
    Serial.println("Connection failed.");
  }
  else if (WiFi.status() == WL_CONNECTED) {
    Serial.print("WiFi connected in ");
    Serial.print(intervals);
    Serial.println(" intervals");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
    digitalWrite(LED_BUILTIN, HIGH);
  }

  Serial.println("Setup done");
}
//===============================================================================
//  Main
//===============================================================================
void loop() {
  WiFiClient client;
  HTTPClient http;

  Serial.println("Enter something to continue.");
  while (Serial.available()) {};

  http.begin(client, actionURL);
  int httpResponseCode = http.GET();
      
  if (httpResponseCode>0) {
    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);
    Serial.println("HTTP Payload:");
    String payload = http.getString();
    Serial.println(payload);
  }
  else {
    Serial.print("Error code: ");
    Serial.println(httpResponseCode);
  }
  // Free resources
  http.end();
  delay(5000);
}