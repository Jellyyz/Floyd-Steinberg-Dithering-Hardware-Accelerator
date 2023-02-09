(use [proposal guidelines to write this](https://courses.grainger.illinois.edu/ece445/lectures/Video/ProjectProposalSlides.pdf), [our project link](https://courses.engr.illinois.edu/ece445/pace/my-project.asp), [proposal rubric download](https://docs.google.com/document/d/131oiTYIWipWVZ5uxYgSXWuzB4SeM41vfHetalnSdHdE/export?format=pdf))
# Introduction

Our senior design project name is **Portable Thermal Printer** for ECE 445 Spring 2023.

We are team 29, with the assistance of TA Shao Hanyin (hanyins)
- Gally Huang
- Jason Liu
- Kevin An


## Objectives and Background
### Introduction
#### Problem:
One of the biggest problems surrounding frequent travellers is the issue of portability. Items that are carried along cannot weigh too much, consume too much space, and compromise on quality. A target area that has been identified by Hewlett Packard Inc. (HP) lies within the commercial printer industry. Printers as a whole have remained relatively unchanged over time with respect to other technologies that have shifted towards more portable means, and still remains an inconvenience for travellers who need to print items while 
, and HP has identified a potential entry into the portable printer market. 
 
#### Solution:

Our solution is a portable thermal printer, a system that receives wireless instructions for printing on receipt paper. Users will be able to upload images from their phones or computer that this system can fetch and print.

We will use an FPGA to implement our solution because they can stand in place for a real-world ASIC and eventually be developed in an ASIC. It will be utilized as the base of the project. Additionally, we need to have a way to print, so we will be using the internals of a thermal printer. Finally, we will be creating our own IO shield for the PCB that has the subsystems listed further down on top of it. 

#### Visual Aid:
## Block Diagram
![Diagram](https://raw.githubusercontent.com/Jellyyz/ECE445/main/Proposal445_pictorial.drawio.png)

#### Goals and Benefits
- Make printing portable in the world where many other technology have already evolved to become more portable. <!-- Goals -->
- Current solutions using wireless connection usually support Bluetooth, which is short-range, or are expensive. <!-- Features -->
- The project allows for printing with a battery system and wireless uploading of image data, making it very portable. <!-- Functions / Benefits -->

#### High Level Requirements <!-- 3/3 sentences: max of 3 sentences -->

- The device design is portable. It should be able to wirelessly and accurately get the user uploaded image data from a server to the embedded microcontroller. The device itself should also be completely powered by batteries, having an average (if not worst case) battery life of ideally 1.5 or more hours. Last, it should sit as a small footprint of dimensions at most 4inx8in, able to fit entirely in someone's hand for convenience and ease of carrying.
- When the data is processed by the FPGA, we expect to see considerable tradeoffs in runtime as opposed to performing the image processing algorithms sequentially using the microcontroller alone. We will compare runtimes in implementations between traditional means on the microcontroller (where the algorithms have quadratic runtime scaling), and the hardware accelerated version on the FPGA to demonstrate the boost in performance throughout the entire process time. The end to end time, between user upload to completing the printing, should be within 15 seconds so as to not consume too much time for the user. 
- The printer itself needs to operate at over 150 degrees Fahrenheit in order to activate the thermal paper, and therefore we must ensure, for the safety of the device for the user, that the specific area intended to be held by the user remains under 120 degrees Fahrenheit throughout operation. The reason for 120 degrees Fahrenheit is because this is generally agreed upon for handheld products as the upper limit of a safe-to-touch temperature, and it would be extremely detrimental if the device were to cause harm by exceeding this rating.


# Design

## Block Diagram
![Diagram](https://raw.githubusercontent.com/Jellyyz/ECE445/main/Proposal/445_proposal.drawio.png)

### Description

### WiFi Subsystem
##### WiFi Subsystem Overview:

The purpose of the WiFi subsystem is for the system to wirelessly connect between a server (can be locally hosted on a computer or on the cloud), a user, and the ESP8266 microcontroller. The benefits of this subsystem add portability for the product and a more “polished” feel for the user, reducing the need for excessive cables and clutter. 

There will be a simple webpage backed by the server that a user can interface with and upload an image to, and upon which the user can request a connected printer to print the uploaded image. The server will send data to the microcontroller through a wifi connection between the microcontroller to the server, in which the microcontroller further processes the data upon receiving it.

##### WiFi Subsystem Requirements:

ESP8266 Microcontroller: This low cost MCU will be embedded on the custom PCB (we will design this as an IO Shield for the system’s FPGA). With respect to the wireless functionality, it is responsible for allowing the printer system itself to stay wireless, as it has a built-in WiFi microchip enabling simple connection to an application server (discussed below). With the MCU acting as a client to an application server, it can create something such as HTTP requests and receive data from the application that users can upload an image to (can be programmed to perform requests at certain intervals, manual button press, etc.).  

This MCU will then be responsible for delivering the image data to a buffer for the FPGA to further process towards printing, taking advantage of the FPGA for hardware acceleration in implementing DSP algorithms (such as the Floyd-Steinberg dithering algorithm) in order to speed up the image manipulation and cleaning processes. It will also send diagnostic data about the state of the current processes to an LCD display, such as about current battery status, ready for printing acknowledgement, paper jam, etc.

The link to the ESP8266 SMT Module: https://www.adafruit.com/product/2491

Application server: A server which allows the user (when connected) to upload an image through a computer or cell phone, and enables the ESP8266 MCU to receive the data through a request following the event. The frontend can be created with a simple interface (HTML/CSS/basic JS) that allows users to upload an image, and an on-screen button which flags the image as ready to be delivered to the MCU upon the next request. The backend can be handled with Django and an API which allows the user to actually upload the image on the server and for the MCU to get an encoded version of the to-be-printed image (ie. through base 64 string encoding in a JSON) from the server.

As mentioned, the server can be hosted locally for the scope of this project as-is, especially as a means of saving a consistent amount of money as opposed to hosting on a commercial  cloud platform such as AWS or GCP. For large scale implementation, we of course cannot rely on local servers, but this simplifies our testing requirements with a small sample set of users and devices to work with.

The MCU will require 12 mA of current and anywhere between 3-3.3V continuously for operation, which we define in the Power Subsystem how this will be delivered. The local server, being hosted a computer, will require power delivered through a commercial power adapter supply (ie. laptop being powered by a laptop charger), however, we allow this to be hidden from view for the user. 


### Risk Analysis

Servers are considered outside the scope of this class, so it may be difficult to implement. Additionally, based on our implementation of accepting data from a user, we can have our local server (and hence, our local device) be susceptible to a cyber attack. Using JavaScript makes us potentially vulnerable to some control flow hijacking, which can allow users to attack our device. Since our code is online, attackers can try to precisely send images to hijack the server.

### Image Processing Subsystem
##### Image Proocessing Subsystem Overview:

This subsystem allows for a three pixels to be converted and mapped into the dithered equivalent after being processed. The processing is done entirely by hardware as this is the "hardware accelerator" portion of our project and this will allow for the images to be printed out at an incredible rate in a very similar fashion to how it is done in industry with consumer grade printers @ HP. 


##### Image Processing Subsystem Requirements:

A Delite-10 FPGA will be utilized to simulate the operation of an ASIC which is not openly avaliable to the mass public. FPGAs are commonly used to test HDL code at a very cheap cost compared to a full scale tape out - albeit at a slower clock, so we will attempt to multiply our hardware throughput at the correct porportional speedup rate. The de-lite 10 can run at a speed of 50mhz, while mainstream ASICs can usually run 10 - 50x faster than this, but this still will be much faster than processing the image through software means (on the cloud or on the MCU). 

The fpga will take in 3 pixels and run it through a pipeline. Firstly the fpga must store all of the RGB values of an image into its on board memory in order to prepare it to processed. In this case, while the pixels are being stored into memory, we can start processing some of the data while it is still in the process of gathering data from the microcontroller. This is because many of the algorithms that will be applied such as Floyd-Steinberg dithering only requires 5 adjacent pixels for the image to start being processed. We need to set up a state machine that detects whenever a threshold amount of pixels have been loaded into the fpga and it will start to process this data simultanously. The third stage of the pipeline is when the data needs to be stored in a final bitmapped processed stage and then this final image will be sent back out into the microcontroller/wifi submodule and it will be ready for printing. This process happens super fast, and doing the math it should not take more than 3(pipeline stages) * (x * y) = 3xy, where x and y are the dimensions of the picture,  clock cycles in order to process a single image. 

Diagram:
![Diagram](https://raw.githubusercontent.com/Jellyyz/ECE445/main/Proposal/fpga_image_processing.drawio.png)

### Board Subsystem
##### Board Subsystem Overview:
The board subsystem is the interactive and diagnostic block that allows for the user to check the status of the entire system at a glance.

The components are a small 1.8" raw TFT display that displays information about the battery level and the status of a printing job.

There will be an infrared receiver sensor that will sense if there is still a supply of receipt paper for the thermal printer to print on. This information will be sent to the MCU, which will program the LCD to print out a warning or error.

Finally, there will be a switchbox that the user can use. Switches, when turned on and off, will change what algorithm the FPGA will use when processing the image (e.g., Floyd-Steinberg Dithering).
##### Board Subsystem Requirements:
The LCD must be able to

### Power Subsystem
##### Power Subsystem Overview:
The power subsystem supplies power to every other subsystem. Namely, it powers components such as the ESP8266 MCU (3-3.3V), the thermal printer (5-9V), the FPGA (5V), the LCD (3.3V), and the infrared sensor (3-5V). Its components are a USB-C controller that will be connected to a PC's USB-C port. This connection will supply power to our four 18650 batteries. We use a regulator system to maintain constant voltage levels to the components stated above. It will also flash the MCU (send program information to the MCU to execute).

This subsystem as a whole is necessary for the operations of displaying constant diagnostic information, the Wireless Subsystem receiving image data, processing image data, and printing an image.

##### Power Subsystem Requirements:
The other subsystems must be powered on with this subsystem at the stated voltage and current levels or with a maximum of -5% deviation.

We also must be able to check the current battery level percent of the 18650 batteries on the LCD in the Board Subsystem.

# Ethics and Safety

We believe that this design is quite safe since most of the components are found in everyday objects such as a phone and other consumer grade products. However, we take some ideas from prior consumer failures, such as the samsung s7 battery that exploded and imploded on itself due to a manufactoring defect. 

We should be testing the battery throughly in order to ensure that it is not causing for any power overages to occur as well as any harm to the user. This includes setting up battery current limitations as well as limitations on how much the battery can charge. By limiting the amount of things that the battery can do, this will in turn cause for the most voltile part of the system to be the most safe. 
