#include "lodepng_helper.h"
#include "floyd_steinberg.h"

const int BUTTON_PIN = D6;    // Define pin the button is connected to

const int CONNECTION_LIMIT_INTERVALS = 25;
const int CONNECTION_INTERVAL_TIME = 250;

using namespace std;

void setup() {
  // put your setup code here, to run once:
  pinMode(LED_BUILTIN, OUTPUT);       // Initialize the LED_BUILTIN pin as an output
  pinMode(BUTTON_PIN, INPUT_PULLUP);  // Initialize button pin with built-in pullup.
  digitalWrite(LED_BUILTIN, HIGH);    // Ensure LED is off
  Serial.begin(115200);               // Set comm rate to 115200

  Serial.println("Setup done");

  string encoding = "iVBORw0KGgoAAAANSUhEUgAAAEAAAAAQCAYAAACm53kpAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAACsSURBVFhH7ZVRDkAwDEA7CYfhEBydQ3AYPli3VWKIbvZB1vex+mm6tM+qVg1oGoUnnwlsgkuHbjGBzVAd82Prt7PNj6VwMVtUrWeAH6PXyKeJ+BPoSxN2nowgA3R9E/36d9C9xIBEnAzg/ot3BnDfglQG0BsSS/YG7A3AznKnfwVOPnQTfAExwMVskS1AWyCUt3s41Rag/FjEgK8YEIoYkAhs47sW/pzMDQDYAOmjSaL5WFgHAAAAAElFTkSuQmCC";
  vector<unsigned char> png;
  fromBase64(png, encoding);

  for (std::vector<unsigned char>::iterator it = png.begin(); it < png.end(); it++) {
      Serial.print(*it);
  }
  Serial.println("\0");
  for (int i = 0; i < png.size(); i++) {
      Serial.write(png[i]);
  }
  Serial.println("\0");

  vector<unsigned char> img;
  unsigned w, h;
  lodepng::State state;

  /* assumed each R, G, and B value is a byte and no need for Alpha */
  state.info_raw.bitdepth = 8;
  state.info_raw.colortype = LodePNGColorType::LCT_RGB;

  ASSERT_NO_PNG_ERROR(lodepng::decode(img, w, h, state, png));

  
  Serial.println(F("Done."));
  Serial.print(F("w = "));
  Serial.println(w);
  Serial.print(F("h = "));
  Serial.println(h);
  Serial.print(F("size = "));
  Serial.println(img.size());

  for (int i = 0; i < 100; i++) {
      Serial.print(i);
      Serial.print(F(" : "));
      Serial.println(img[i]);
  }
}

void loop() {
  // put your main code here, to run repeatedly:

}
