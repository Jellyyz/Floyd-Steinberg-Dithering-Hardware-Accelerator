
# Portable Thermal Printer

Team Members:
- Gally Huang (ghuang23)
- Jason Liu (jliu246)
- Kevin An (kqan2)

# Problem

In such a modern world with many other products such as smartphones and the internet, the printer has remained relatively unchanged over the course of the last century. After electronics were invented, the art of printing was modernized in a way that allowed printing with electricity. In order to stay competitive, Hewlett Packard Inc. (HP) has set out a pitch for us to attempt to discover a way to make printing portable in order to keep their high market share over the printing market. Competitors such as Canon Inc. have already begun the process of creating such portable printers in the Asian markets and this will allow us to design and create smaller printers in the NA market. 

# Solution

A system that receives instructions for printing wirelessly that can process image data and print the corresponding image on receipt paper. This system would allow for portable printing capabilities at low costs.

We will use an FPGA to implement our solution because FPGAs can stand in place for a real-world ASIC. We can mass produce it eventually to be much more cost-efficient to market for the consumer and add the WiFi capabilities on a PCB alongside the FPGA. For our purposes, the FPGA serves as an emulation tool that is similarly used at HP for their standalone printers that can eventually be developed in an ASIC. 

The FPGA from ECE 385 will be utilized as the base of the project. We will be creating our own IO shield for the PCB that has the components described below (LCD, Wifi, Printer, and LEDs) that go on top of it. Since the printer requires a higher voltage than that of the FPGA, we will also need to figure out a way to shape the PCB to power all the components on 9/5/3.3V power rails. 

# Solution Components

## Imaging Subsystem

- As image data is input, it will process the data to a black-and-white image.
- ALTERA MAX10 Development & Education Board (DE10-Lite) (i.e., from ECE 385)
- Thermal Receipt Printer Guts (https://www.mouser.com/datasheet/2/737/mini_thermal_receipt_printer-2488648.pdf) to print images onto receipts. Since it's the guts of a printer, we will be making a secure enclosure for it and connecting it to the MCU and FPGA using a PCB. 

## WiFi Subsystem

- Communicate between our system and simple backend server via WiFi.
- ESP8266 SMT Module - ESP-12F WiFi module (https://www.adafruit.com/product/2491)
- Wifi Subsystem on IO Shield for FPGA to receive data. 

## Diagnostic Subsystem

- LEDs that indicate the success or failure of the printing and imaging process.

### If we manage to achieve the above, the following will be added to the system:

## Sensor / Actuator Subsystem

- It will output information about the printer battery level, printed image preview, and other diagnostic data to an LCD.
- 1.8" SPI TFT display, 160x128 18-bit color - ST7735R driver (https://www.adafruit.com/product/618)
- Buttons that decide what imaging algorithm to use when processing images.

## Power Subsystem

- Batteries supply power to the thermal printer and auxiliary components.
- If the printer is not executing, the system should be in an idle state and draw less power. The WiFi Module already has features to enable this (modem-sleep mode). We should try to see if there is a similar solution for the printer.
- We need to account for the fact that not all the components use the same amount of voltage. So there must be some logic to stepping down the voltage. 
- We will require some guidance on the correct battery layout since all of our knowledge on battery systems is quite limited but we received some suggestions to use 18650 batteries in their correct layout in series and parallel to supply the correct power. 
    - The FPGA, LCD display, and WiFi Module will be < 5V. 
    - The thermal printer requires 5V-10V to operate, 7.5V-9V DC for best results at 1.5A current. 

# Criterion For Success

1. We need to make sure that the device is able to process data on its own through its hardware. We shall implement algorithms suggested to us by HP (e.g., Floyd-Steinberg dithering algorithm) on an FPGA. 
2. The printed image must be the same as the image sent to the wireless subsystem except in black and white and fitted on receipt paper.
3. We need to use small printers.
4. We need to make sure that the device design is portable, in that it is able to receive data through WiFi and is battery-powered. 