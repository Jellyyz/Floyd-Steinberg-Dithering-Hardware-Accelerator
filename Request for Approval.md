
# Portable Thermal Printer

Team Members:
- Gally Huang (ghuang23)
- Jason Liu (jliu246)
- Kevin An (kqan2)

# Problem

Printing has become a commodity in the modern world with many applications that require it, from the educational sector of our society to the military. In such a modern world with many other products such as smartphones and the internet, the printer has remained relatively unchanged over the course of the last century. After electronics were invented, the art of printing was modernized in a way that allowed printing with electricity. In order to stay competitive, Hewlett Packard Inc. (HP) has set out a pitch for us to attempt to discover a way to make printing portable in order to keep their high market share over the printing market. Competitors such as Brother have already begun the process of creating such portable printers in the Asian markets and this will allow us to design and create smaller printers in the NA market. 

# Solution

A system that receives instructions for printing wirelessly that can process image data and print the corresponding image on receipt paper. This system would allow for portable printing capabilities at low costs.

We will use an FPGA to implement our solution because FPGAs can stand in place for a real world ASIC. We can mass produce it eventually to be much more cost efficent tomarket for the consumer and add the WiFi capabilties on a PCB alongside the FPGA. For our purposes, the FPGA serves an emulation tool that is similarly used at HP for their standalone printers that can eventually be developed in an ASIC. 

# Solution Components

## Imaging Subsystem

Explain what the subsystem does.  Explicitly list what sensors/components you will use in this subsystem.  Include part numbers.

- As image data as input, it will process the data to a black and white image.
- ALTERA MAX10 Development & Education Board (DE10-Lite) (i.e., from ECE 385)
- DE10-Lite Shield
- Thermal Receipt Printer Guts (https://www.mouser.com/datasheet/2/737/mini_thermal_receipt_printer-2488648.pdf) to print images on to receipts. Since it's the guts of a printer, we will be making a secure enclosure for it.

## WiFi Subsystem

- Communicate between our system and another device via WiFi.
- ESP8266 SMT Module - ESP-12F WiFi module (https://www.adafruit.com/product/2491)

## Diagnostic Subsystem

- LEDs that indicate success or failure of the printing and imaging process.

### If we manage to achieve the above, the following will be added to the system:

## Sensor / Actuator Subsystem

- It will output printer battery, file to print, and other diagnostic data to an LCD. 
- HD44780 LCD (https://www.sparkfun.com/datasheets/LCD/HD44780.pdf)
- Buttons that decide what imaging algorithm to use when processing images.

## Power Subsystem

- Supplies power to the thermal printer.
- Printer requires 7.5V-9V DC for clear printing, 1.5A.
- If the printer is not executing, the system should not be on.


# Criterion For Success

Describe high-level goals that your project needs to achieve to be effective.  These goals need to be clearly testable and not subjective.

1. We need to make sure that the device is able to process data on its own through its hardware. We shall implement an algorithm suggested to us by HP (half toning algorithm) on an FPGA. 
2. The printed image must be the same as the image sent to the wireless subsystem except black and white and fitted on receipt paper.
3. We need to use small printers.
4. We need to make sure that the device design is portable, in that it is able to receive data through WiFi and is battery powered. 