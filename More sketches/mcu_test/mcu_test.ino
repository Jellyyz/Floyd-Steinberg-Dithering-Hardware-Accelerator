/*
 *  This sketch demonstrates how to scan for and connect to available WiFi networks.
 *  Just type "Scan" into the Serial Monitor (No Line Ending) to output a list of WiFi networks locally.
 *  And type "Connect" into the Serial Monitor (No Line Ending) to connect to a specific network with a specific password (user inputs).
 */
#include "ESP8266WiFi.h"

const int BUTTON_PIN = D6;    // Define pin the button is connected to

const int CONNECTION_LIMIT_INTERVALS = 25;
const int CONNECTION_INTERVAL_TIME = 250;
//===============================================================================
//  Initialization
//===============================================================================
void setup() {
  pinMode(LED_BUILTIN, OUTPUT);       // Initialize the LED_BUILTIN pin as an output
  pinMode(BUTTON_PIN, INPUT_PULLUP);  // Initialize button pin with built-in pullup.
  digitalWrite(LED_BUILTIN, HIGH);    // Ensure LED is off
  Serial.begin(115200);               // Set comm rate to 115200

  // Set WiFi to station mode and disconnect from an AP if it was previously connected
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  delay(100);

  Serial.println("Setup done");
}
//===============================================================================
//  Main
//===============================================================================
void loop() {
  Serial.println("Command?");
  while (Serial.available() == 0) {}
  String input = Serial.readString();
  Serial.println(input);
  if (input == "Scan") {
    Serial.println("Scan start");
    digitalWrite(LED_BUILTIN, LOW);       // Turn LED ON 
    // WiFi.scanNetworks will return the number of networks found
    int n = WiFi.scanNetworks();
    Serial.println("Scan done");
    if (n == 0)
      Serial.println("No networks found");
    else
    {
      Serial.print(n);
      Serial.println(" networks found");
      for (int i = 0; i < n; ++i)
      {
        // Print SSID and RSSI for each network found
        Serial.print(i + 1);
        Serial.print(": ");
        Serial.print(WiFi.SSID(i));
        Serial.print(" (");
        Serial.print(WiFi.RSSI(i));
        Serial.print(")");
        Serial.println((WiFi.encryptionType(i) == ENC_TYPE_NONE)?" : Unsecure":" : Encrypted");
        delay(10);
      }
    }
    digitalWrite(LED_BUILTIN, HIGH);
  }
  else if (input == "Connect") {
    Serial.println("Connect to what network name?");
    while (Serial.available() == 0) {}
    String networkName = Serial.readString();
    Serial.println("Network password?");
    while (Serial.available() == 0) {}
    String networkPass = Serial.readString();
    WiFi.begin(networkName, networkPass);

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
  }
}