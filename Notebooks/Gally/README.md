## Lab Notebook

# Jan 18, 2023

This is the initial call with HP. Contacts include my former coworkers and superiors @ HP who are on the Digital ASIC team. They go over the ideas that they have and confirm on the portable printer idea as the best idea. They give us ideas on how to build this project as I explain how the class functions and works. 
Kevin joins in on the call. Jason is unable to make it. 
# Jan 22, 2023 

This is the initial meeting with the entire team. We have recieved a potential pitch from HP who has decided to give us some workload relating to a portable printer. We start very high level planning the idea and are looking for other ideas that are also feasible for our project.

Other ideas that were planned but failed to pass the idea stage:

1. Classroom detector 
2. Fish tank monitor

# Jan 25

I meet with a TA who discusses the feasibility of this project and the requirements meeting. We as a group submit our original RFA by the end of the day, but misses some requirements that Viktor Gruev has mentioned. We add USB functionality to our hardware requirements which increases hardware complexity and this passes the early RFA deadline by tmmr. 


# Feb 6 

I start work on the brainstorming of how the entire system works. The block diagram 1st draft is finished and HDL code is being brainstormed as well. 


# Feb 7

We as a group met with the TA and she gave us some requirements for our project as well as promising to give us an FPGA.

# Feb 9
We as a group met to finish up the proposal.

# Feb 11 
Met with group to hand out work for the week. Kevin shall continue schematic and so will jason, they will try to finish the networking aspect of the project asap. I wil lbe working on the HDL continoully. 

# Feb 13

I finished up some of the image processing HDL as well as the important part of parallezing a lot of the HDL. It is time to meet with the team again soon because I need to understand the format of how the data is being spit out better. 

# Feb 16 

Group meeting with the team to discuss what internals need to be done. The team contract is due soon so we need to prioritize this over everything.
The next couple of days are dedicated to finishing the design document and the team contract. 

# Feb 20th.

I set up a meeting with Professor Gruev going over the basics of what should be expected in our design for the power subsystem. Gruev gave us lots of advice on what batteries to use as well as the reasoning of what we should do for each of the voltage regulators. The team was left satisfied with this high level overview but we are still unsure on the specifics of what we should do in terms of connecting it. Additionally Gally has dedicated a lot of the time slots to each person by now and everyone should be familar on what they should be working on.


# Feb 25th

Because the MCU boards that were ordered weeks ago never came in, Gally has decided to order the esp8266 12f boards manually in order to try to expediate the process of attempting to work on them. Boards are then therefore distributed to Kevin and Jason during this time period and we are attempting to try to get it to work.

# Feb 26 

Jason has informed me that he able to get SPI working between the FPGA and the microcontroller. I then informed him to try and get the MCU to work with the FPGA with a hexdriver. In this case then we will be able to see what is going to go on between the transaction between the master and slave. Additionally we should try to figure out SCLK and SS soon as well. 

# March 2 

We met at Beckman in order to try and finish up the reformed Proposal and finalize the details for it. Additionally Kevin has informed me that he was able to get some of the server working. We should try to finish it before break.

# March 4 

The team met today on the first floor of the ECEB. The rest of the team is attempting to fix and finish up the server on the MCU while I began to do some research on how to do the power electronics of the project. It appears that PCB design is also not an easy task because we see that every component has a different size and there are a lot of different ways to implemnent it. 

# March 5 

I have finished up a schematic for the PCB and we see that it appears to be working. However EagleCad which is what I was doing appears to be less user friendly compared to KiCad. I will begin to transfer everything to KiCad within the next day.

# March 7 

The PCB is complete as well as the schematic. Everything is now on KiCad and I passed DRC. I additionally informed my superiors at HP about our progress and they are impressed. We should discuss figuring out the image subsystem soon with the FPGA and the Printer.

# March 9

We met in Beckman in order to try and figure out the specifics on how to do the FPGA <-> MCU interaction. SPI is definetely the correct protocol to use, however we are seeing that we might require some specific wires to indicate whenever data is being transmitted and when it is being recieved. We created a diagram to try and visualize what it may look like.


Slave

![image](https://github.com/Jellyyz/ECE445/blob/main/Notebooks/Jason/Slave.jpg)


# Spring Break

I have finished the basic outline of the FPGA archiecture. I moved all of the buffers from an architecture that relies on the LUTs to the on chip memory on the FPGA. However this comes with its own discrepancies as we now have to index it into an address rather than the [x][y] that the registers are capable of using the LUTs. In addition to this I experimented with using single port vs dual port RAM and decided dual port RAM is better, even if we decided to use only one pair of ports for now so we open up the possibility of pipelining our calculations later.

Additionally I have finished the basic state machine to process data. The data right now is completely wrong but it is a start for Jason to work off of until I have everything else completed. 

It also appears that Kevin has finished the server and I assigned to him to the printer and the power PCB workings since he is the strongest person for soldering on our team. He will have to figure out how to interact with the USB-C PD controller, and test if the PCB is working correctly.

Jason is assigned the LCD firmware and is responsible for getting that working. He also needs to finish up a SPI controller since the SPI only sends out 1 bit at a time he needs to pack it up to 8 bits a time to be stored inside sram. 


