
# Portable Thermal Printer

Team Members:
- Gally Huang (ghuang23)
- Jason Liu (jliu246)
- Student 3 (netid)

# Problem

Printing has become a commodity in the modern world with many applications that require it, from the educational sector of our society to the military. In such a modern world with many other products such as smartphones and the internet, the printer has remained relatively unchanged over the course of the last century. After electronics were invented, the art of printing was modernized in a way that allowed printing with electricity. In order to stay competitive, Hewlett Packard Inc. (HP) has set out a pitch for us to attempt to discover a way to make printing portable in order to keep their high market share over the printing market. Competitors such as Brother have already begun the process of creating such portable printers in the Asian markets and this will allow us to design and create smaller printers in the NA market. 

# Solution

A system that receives instructions for printing wirelessly that can process image data and print the corresponding image on receipt paper. This system would allow for portable printing capabilities at low costs.

We will use an FPGA to implement our solution because FPGAs can stand in place for a real world ASIC. We can mass produce it eventually to be much more cost efficent tomarket for the consumer and add the WiFi capabilties on a PCB alongside the FPGA. For our purposes, the FPGA serves an emulation tool that is similarly used at HP for their standalone printers that can eventually be developed in an ASIC. 

# Solution Components

## Processing Subsystem

Explain what the subsystem does.  Explicitly list what sensors/components you will use in this subsystem.  Include part numbers.

- As image data as input, it will process the data to a black and white image via the digital halftoning algorithm.
- ALTERA MAX10 Development & Education Board (DE10-Lite) (i.e., from ECE 385)
- DE10-Lite Shield

## Wireless Subsystem

- ___ Microcontroller with ESP8266(?) WiFi module

## Sensor Subsystem

- 

# Criterion For Success

Describe high-level goals that your project needs to achieve to be effective.  These goals need to be clearly testable and not subjective.

1. We need to make sure that the device is able to receive data through portable methods - in this case, through WiFi. 
2. We need to make sure that the device is able to process data on its own through its hardware. We shall implement an algorithm suggested to us by HP (half toning algorithm) on an FPGA. 
3. The printed image must be the same as the image sent to the wireless subsystem except black and white and fitted on receipt paper.
4. We need to use small printers.