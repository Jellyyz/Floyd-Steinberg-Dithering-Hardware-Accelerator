#include "SPI.h"

/* Plug in to the pins labeled D */
#define TEST_INPUT D1
#define HSPI_CLK D5
#define HSPI_MISO D6
#define HSPI_MOSI D7
#define HSPI_SS_FPGA D8
#define HSPI_SS_LCD D2

#define SLOW_MO_CLK_FREQ 20000
#define CLK_FREQ 20000000

/* SPISettings(Max SCLK speed, Data transfer type, SPI mode) */
const SPISettings FPGASettings = SPISettings(SLOW_MO_CLK_FREQ, MSBFIRST, SPI_MODE0);

void setup() {
  /* Use baud rate of 115200 in Serial Monitor. */
  Serial.begin(115200);
  Serial.println(F("Startup exec."));
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);  // Turn off LED.

  /* Slave select pinout setup. */
  pinMode(HSPI_SS_FPGA, OUTPUT);
  digitalWrite(HSPI_SS_FPGA, HIGH);
  pinMode(HSPI_SS_LCD, OUTPUT);
  digitalWrite(HSPI_SS_LCD, HIGH);

  /* Initializes the SPI bus by setting SCK, MOSI, and SS to outputs, pulling SCK and MOSI low, and SS high.
   * Cannot override these pins anymore with digitalWrite().
   * Must call begin() before configuring anything else to SPI. */
  SPI.begin();
  Serial.println(F("Setup for simple SPI test complete."));
}

void loop() {
  /*
   * FPGA SPI communication loop.
   */
  byte receive, send;
  for(int i = 0; i < 10; i++) {
    /* If `SS` was set somehow, impending doom... */
    if (digitalRead(HSPI_SS_FPGA) == LOW) {
      Serial.println(F("ERR: Slave selected already (SS = 0)."));
    }
    else {
      /* Expect slave to read in 'C' and '7' alternating. */
      send = (i % 2) ? 0b11111100 : 0b01010111;

      digitalWrite(HSPI_SS_FPGA, LOW);  /* Select FPGA. */
      SPI.beginTransaction(FPGASettings);
        receive = SPI.transfer(send); /* Start SPI transaction (send and receive a byte) with the global settings. */
      SPI.endTransaction();
      digitalWrite(HSPI_SS_FPGA, HIGH); /* Deselect FPGA. */

      {
        Serial.print(F("Received slave data: "));
        Serial.println(receive);
      }
    }
    /* Delay so that byte hexadecimal display can be reasonably perceived. 
     * With some delay, expect SCLK to be mostly LOW, MOSI to be mostly LOW, SS to be mostly HIGH.
     */
    delay(200);
  }
  Serial.println();
}
