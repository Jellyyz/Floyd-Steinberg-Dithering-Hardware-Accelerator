/*
 *  This sketch demonstrates uploading an image to your server given a vector of bytes that represent an image (.png).
 */

// Req. for server
#include <WiFi.h>
#include <HTTPClient.h>

// Req. for imaging
#include "lodepng_helper.h"
#include "SPI.h"
#include <vector>

// Req. for printing
#include "Adafruit_Thermal.h"
#include <HardwareSerial.h>

using namespace std;

#define TX_PIN 17 // Arduino transmit  YELLOW WIRE  labeled RX on printer
#define RX_PIN 16 // Arduino receive   GREEN WIRE   labeled TX on printer

// Add 2.4 GHz network and password here
const char *SSID = "DESKTOPDC6RH4K0083";
const char *PASS = "wX]37869";
const uint16_t port = 8585;
const char* host = "10.192.175.94";//"192.168.10.8";

const int CONNECTION_LIMIT_INTERVALS = 35;
const int CONNECTION_INTERVAL_TIME = 250;

WiFiClient client;

/* Plug in to the pins labeled D */
#define VSPI_CLK 18
#define VSPI_MISO 19
#define VSPI_MOSI 23
#define VSPI_SS_FPGA 5
#define REQUEST 4
#define TRUE_RST 21

#define BUF_SIZE 8
#define SLOW_MO_CLK_FREQ 20000
#define CLK_FREQ 10000000

/* SPISettings(Max SCLK speed, Data transfer type, SPI mode) */
const SPISettings FPGASettings = SPISettings(CLK_FREQ, MSBFIRST, SPI_MODE0);
SPIClass SPI_FPGA = SPIClass(VSPI);

Adafruit_Thermal printer(&Serial2);

#   define B2(n) n,     n+1,     n+1,     n+2
#   define B4(n) B2(n), B2(n+1), B2(n+1), B2(n+2)
#   define B6(n) B4(n), B4(n+1), B4(n+1), B4(n+2)
const unsigned char BitsSetTable256[256] = 
{
    B6(0), B6(1), B6(1), B6(2)
};

//===============================================================================
//  Initialization
//===============================================================================
void setup() {
    /* printer setup */
    Serial2.begin(9600, SERIAL_8N1, RX_PIN, TX_PIN);
    printer.begin();        // Init printer (same regardless of serial type)

    Serial.begin(115200);

    WiFi.begin(SSID, PASS);             // Connect to the network
    Serial.print("Connecting to ");
    Serial.print(SSID);
    Serial.println(" ...");


    /* Slave select pinout setup. */
    pinMode(VSPI_SS_FPGA, OUTPUT);
    digitalWrite(VSPI_SS_FPGA, HIGH);

    pinMode(TRUE_RST, OUTPUT);
    digitalWrite(TRUE_RST, HIGH);

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

    uint32_t freeHeap = ESP.getFreeHeap();

    Serial.printf("(SETUP) free: %5ld\n", freeHeap);

    
    SPI_FPGA.begin();
}
//===============================================================================
//  Main
//===============================================================================
void loop() {
  uint32_t freeHeap = ESP.getFreeHeap();
  uint32_t maxBlock;

  uint8_t *image_data = nullptr;
  int true_h_packet[2] = {0, 0};
  int true_w_packet[2] = {0, 0};
  int true_w = 0, true_h = 0;

  while (true) {
    if (!client.connect(host, port))
    {
        delay(1000);
        return;
    }

    Serial.println("Connected to server!");

    delay(250);
    int i = 0, j = 0;

    // every byte is padded to 8 bits (0 => white, 1 => black)
    // such that w * h is a power of 2 as specified in FPGA
    true_h = 0, true_w = 0;
    image_data = nullptr;
    
    uint32_t num_bytes = true_w * true_h;
    uint32_t mask = 0b1 << 31;
    bool is_power_of_2 = false;
    int row = 0, col = 0;
    while (client.available()>0)
    {
      uint8_t byte_got = static_cast<uint8_t>(client.read());
      switch (i) {
        case 0:
          true_w = static_cast<int>(byte_got) << 8;
          true_w_packet[0] = static_cast<int>(byte_got);
          break;
        case 1:
          true_w += byte_got;
          true_w_packet[1] = static_cast<int>(byte_got);
          break;
        case 2:
          true_h = static_cast<int>(byte_got) << 8;
          true_h_packet[0] = static_cast<int>(byte_got);
          break;
        case 3:
          true_h += byte_got;
          true_h_packet[1] = static_cast<int>(byte_got);
          num_bytes = true_w * true_h;

          Serial.println(F("Allocating..."));
          freeHeap = ESP.getFreeHeap();

           Serial.printf("(SETUP) free: %5ld\n", freeHeap);

           maxBlock = ESP.getMaxAllocHeap();

           Serial.printf("(SETUP) max block: %5ld\n", maxBlock);
          
          image_data = new uint8_t[66536] {};
          Serial.print(F("Allocated image buffer of size 66536 for "));
          Serial.println(true_w * true_h);
          break;
        default:
        // For now, expect 0 (black) => 0b1 (black), 255 (white) => 0b0 (white)
          image_data[row * true_w + col] = byte_got;
          col++;

          if (col == true_w) {
            // done with curr row
            row++;
            col = 0;
          }
          
          break;
        }
        i++;
    }
    Serial.println(i);
    Serial.print(" bytes registered from server\n");
    if (true_w * true_h != 0) {
      break;
    }
  }

  client.stop();
  delay(1000);

  // Send and then receive from FPGA

  // Verifier pt. 1:
  
  for (size_t i = 0; i < 1; i++) {
    Serial.print(i);
    Serial.print(F(" : "));
    for (size_t j = 0; j < true_w; j++) {
      Serial.print(image_data[i * true_w + j]);
      Serial.print(F(" "));
    }
    Serial.println(";");
  }
/*
  for (size_t i = 0; i < h; i++) {
    for (size_t j = 0; j < true_w; j++) {
      Serial.print(image_data[i * true_w + j]);
      Serial.print(F(","));
    }
    Serial.println("");
  }*/
  SPI_FPGA.beginTransaction(FPGASettings);
    digitalWrite(TRUE_RST, LOW);
    SPI_FPGA.transfer(0xEC);
    digitalWrite(TRUE_RST, HIGH);
  SPI_FPGA.endTransaction();
  delay(5);

  SPI_FPGA.beginTransaction(FPGASettings);
    SPI_FPGA.transfer(true_w_packet[0]);
  SPI_FPGA.endTransaction();
  delay(5);
  SPI_FPGA.beginTransaction(FPGASettings);
    SPI_FPGA.transfer(true_w_packet[1]);
  SPI_FPGA.endTransaction();
  delay(5);

  SPI_FPGA.beginTransaction(FPGASettings);
    SPI_FPGA.transfer(true_h_packet[0]);
  SPI_FPGA.endTransaction();
  delay(5);
  SPI_FPGA.beginTransaction(FPGASettings);
    SPI_FPGA.transfer(true_h_packet[1]);
  SPI_FPGA.endTransaction();
  delay(5);

  SPI_FPGA.beginTransaction(FPGASettings);
    SPI_FPGA.transfer(0xEC);
  SPI_FPGA.endTransaction();
  delay(5);

  
  

  SPI_FPGA.beginTransaction(FPGASettings);
      digitalWrite(VSPI_SS_FPGA, LOW); 
      SPI_FPGA.transfer(image_data, 66536);
      digitalWrite(VSPI_SS_FPGA, HIGH);
  SPI_FPGA.endTransaction();

  Serial.println("Finished SPI transfer...");

  while (1) {
    delay(1);
    if (digitalRead(REQUEST) == HIGH) {
      break;
    }
  }
  delay(10);

  Serial.println("Got past REQUEST");

  // Dummy byte to align byte...
  SPI_FPGA.beginTransaction(FPGASettings);
    digitalWrite(VSPI_SS_FPGA, LOW); 
    SPI_FPGA.transfer(0xEC);
    digitalWrite(VSPI_SS_FPGA, HIGH);
  SPI_FPGA.endTransaction();

  delete[] image_data;

  freeHeap = ESP.getFreeHeap();

  Serial.printf("(SETUP) free: %5ld\n", freeHeap);

  maxBlock = ESP.getMaxAllocHeap();

  Serial.printf("(SETUP) max block: %5ld\n", maxBlock);

  uint8_t *fpga_data = new uint8_t[66536] {};

  SPI_FPGA.beginTransaction(FPGASettings);
    digitalWrite(VSPI_SS_FPGA, LOW); 
    SPI_FPGA.transfer(fpga_data, 66536);
    digitalWrite(VSPI_SS_FPGA, HIGH);
  SPI_FPGA.endTransaction();

  Serial.println("Received buffer");
  if (true_w * true_h <= 2048) {
    for (size_t i = 0; i < true_h; i++) {
        Serial.print(i);
        Serial.print(" : ");
      for (size_t j = 0; j < true_w; j++) {
        uint8_t c = BitsSetTable256[fpga_data[i * true_w + j] & 0xff];
        if (c < 2)
          Serial.print(" 1 ");
        else  
          Serial.print(" 0 ");
      }
      Serial.println("");
    }
  }

  // Verifier pt. 2:
  /*
  for (size_t i = 0; i < h; i++) {
    Serial.print(i);
    Serial.print(F(" : "));
    for (size_t j = 0; j < true_w; j++) {
      Serial.print(fpga_data[i * true_w + j]);
      Serial.print(F(" "));
    }
    Serial.println(";");
  }*/

  // If bytes... bitmap conversion fn:
  freeHeap = ESP.getFreeHeap();

  Serial.printf("(SETUP) free: %5ld\n", freeHeap);
  maxBlock = ESP.getMaxAllocHeap();

  Serial.printf("(SETUP) max block: %5ld\n", maxBlock);

  int true_true_w = true_w;

  while (true_true_w % 8) {
    true_true_w++;
  }

  uint8_t *fpga_bitmap = new uint8_t[(int) (true_true_w / 8) * true_h] {};
  Serial.print("Bitmap is size ");
  Serial.print((int) (true_true_w / 8) * true_h);

  for (int pixel_num = 0, bitmap_idx = 0, bit_index = 7, pixel_x = 0, pixel_y = 0; pixel_num < 65536, pixel_y < true_h; pixel_num++) {
    uint8_t c = BitsSetTable256[fpga_data[pixel_num] & 0xff];
    if (c < 2) {
      fpga_bitmap[bitmap_idx] |= (uint8_t) (1 << bit_index);
    }

    
    pixel_x++;

    if (pixel_x % true_w == 0) {
      // done with curr row
      pixel_num = (pixel_y + 1) * true_w - 1;
      pixel_x = 0;
      pixel_y++;
      bit_index = 7;
      bitmap_idx++;
      continue;
    }

    if (bit_index == 0) {
      bitmap_idx++;
      bit_index = 7;
    }
    else {
      bit_index--;
    }

  }
  
  Serial.println("Created bitmap");

  // Else, don't go the fn.
  // fpga_bitmap is as-is (i.e., the fpga_data)
  //uint8_t *fpga_bitmap = fpga_data;

  // Verifier pt. 3:
  /*
  for (size_t i = 0; i < h; i++) {
    Serial.print(i);
    Serial.print(F(" : "));
    for (size_t j = 0; j < (int) (true_w / 8); j++) {
      Serial.print((int) fpga_bitmap[i * (int) (true_w / 8) + j]);
      Serial.print(F(" "));
    }
    Serial.println(";");
  }*/


  Serial.println("Begin print job.");

  printer.println(F("You requested..."));
  printer.printBitmap(true_true_w, true_h, fpga_bitmap, false);
  
  Serial.println("Done printing...");

  // Free dynamic variables for next loop...
  delete[] fpga_data;
  delete[] fpga_bitmap;


  delay(1000);
}

void print_byte(uint8_t data) {
  Serial.print(data, BIN);
  Serial.print("\t(0b");
  print_bin(data);
  Serial.print(")");
}

void print_bin(uint8_t data) {
  for (unsigned int test = 0x80; test; test >>= 1) {
    Serial.write(data & test ? '1' : '0');
  }
}