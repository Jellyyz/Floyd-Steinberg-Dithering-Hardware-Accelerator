/*
 *  This sketch demonstrates uploading an image to your server given a vector of bytes that represent an image (.png).
 */
#include "ESP8266WiFi.h"
#include "ESP8266HTTPClient.h"
#include "floyd_steinberg.h"
#include "lodepng_helper.h"
#include "b64.h"

// Add 2.4 GHz network and password here
const char *SSID = "foo";
const char *SSID_pass = "bar";

const int CONNECTION_LIMIT_INTERVALS = 35;
const int CONNECTION_INTERVAL_TIME = 250;

// Add http://{host IPv4}:8000{url} assuming server launched with port 8000
const char *actionURL = "http://172.20.10.2:8000/download/get_image";
const char *MCUuploadURL = "http://172.20.10.2:8000/upload/mcu_upload/";
const char *MCUuploadParamURL = "http://172.20.10.2:8000/upload/mcu_upload_param/";

int postImg(String &in, WiFiClient &client);
//===============================================================================
//  Initialization : Connect to SSID with SSID_pass
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

  http.begin(client, actionURL);
  int httpResponseCode = http.GET();
      
  if (httpResponseCode > 0) {
    Serial.print(F("HTTP Response code: "));
    Serial.println(httpResponseCode);
    Serial.println(F("HTTP Payload:"));
    
    // payload is a base64 string... (of most recent image pre-processed [i.e., grayscaled to .png] in media/to_be_dithered/)
    String payload = http.getString();
    Serial.println(payload);

    http.end();

    int uploadHttpResponseCode = postImg2Gray(payload, client, http);
    Serial.print(F("Upload HTTP code:"));
    Serial.println(uploadHttpResponseCode);
  }
  else {
    Serial.print(F("Error code: "));
    Serial.println(httpResponseCode);
  }
  // Free resources
  http.end();
  delay(5000);
}

int postImg2Gray(String &in, WiFiClient &client, HTTPClient &http) {
  // With base64 string `in`, convert to decoded vector `png`, then convert to encoded grayscale vector `img`, then run Floyd-Steinberg on `img`, and then 
  // return `img` to server, which will save it to folder
  Serial.print(F("Size of &in is equal to "));
  Serial.println(in.length());
  Serial.println(F("Post img"));
  vector<unsigned char> png, img;//, final_png;
  fromBase64(png, in);

  Serial.print(F("Size of png is equal to "));
  Serial.println(png.size());
  Serial.print(F("Size of &in is equal to "));
  Serial.println(in.length());

  unsigned w, h;
  lodepng::State state;
  state.info_raw.bitdepth = 8;
  state.info_raw.colortype = LodePNGColorType::LCT_GREY;

  ASSERT_NO_PNG_ERROR(lodepng::decode(img, w, h, state, png));

  Serial.print(F("Size of img is equal to "));
  Serial.println(img.size());

  floyd_steinberg_dithering_serial(img, w, h, false);

  // Delete `png` vector just in case...
  vector<unsigned char>().swap(png);

  int httpResponseCode = -1;
  while (httpResponseCode < 0) {
    // Send over width and height first... so server can reshape easily in format "{w},{h}", where w and h are integers
    http.begin(client, MCUuploadParamURL);
    http.addHeader("Content-Type", "text/plain");
    String params = String(w) + "," + String(h);
    httpResponseCode = http.POST(params);
    http.end();
    delay(100);
  }

  httpResponseCode = -1;
  while (httpResponseCode < 0) {
    // Send over image data... entire grayscale bytearray
    http.begin(client, MCUuploadURL);
    uint8_t *attachPtr = img.data();
    httpResponseCode = http.POST(attachPtr, img.size());
    http.end();
    delay(100);
  }
  delay(250);
  return httpResponseCode;
}