# Title

Team Members:
- Gally Huang (ghuang23)
- Student 2 (netid)
- Student 3 (netid)

# Problem

Describe the problem you want to solve and motivate the need.

Printing has become a commediety in the modern world with many applications that require it, from the educational sector of our society to the military requiring it. In such a modern world with many other products such as smartphones and the internet, the printer has remained relatively unchanged over the course of the last century. After electronics were invented, the art of printing was modernized in the way that allowed it to print with electricity. In order to stay competitive, Hewlett Packard Inc. has set out a pitch for us to attempt to discover a way to make printing portable in order to keep their high market share over the printing market. Competitors such as Brother has already begun the process of creating such portable printers in the Asian markets and this will allow us to design and create smaller printers in the NA market. 

# Solution

Describe your design at a high-level, how it solves the problem, and introduce the subsystems of your project.

In order to support high portability for printing we need to allow for three things to happen.

1. We need to make sure that the device is able to recieve data through portable methods - in this case through wifi. 
2. We need to make sure that the device is able to process data on its own through its own hardware. We shall implement an algorithm suggested to us by HP (insert half toning algorithm) on an FPGA. 
3. We need to be able to utilize a small printer to demonstrate the printing capability after our hardware processes the image processing. 

THe reasoning for an FPGA is because FPGAs can stand in place for a real world ASIC. We can mass produce it eventually to be much more cost efficent to be able to market for the consumer and add the wifi capabilties on a PCB alongside the FPGA. For our purposes, the FPGA serves an emulation tool that is similarly used at HP for their standalone printers that can eventually be developed in an ASIC. 

# Solution Components

## Subsystem 1

Explain what the subsystem does.  Explicitly list what sensors/components you will use in this subsystem.  Include part numbers.

## Subsystem 2

## ...

# Criterion For Success

Describe high-level goals that your project needs to achieve to be effective.  These goals need to be clearly testable and not subjective.