(use [proposal guidelines to write this](https://courses.grainger.illinois.edu/ece445/lectures/Video/ProjectProposalSlides.pdf), [our project link](https://courses.engr.illinois.edu/ece445/pace/my-project.asp), [proposal rubric download](https://docs.google.com/document/d/131oiTYIWipWVZ5uxYgSXWuzB4SeM41vfHetalnSdHdE/export?format=pdf))
# Introduction

Our senior design project name is **Portable Thermal Printer** for ECE 445 Spring 2023.

We are team 29, with the assistance of TA Shao Hanyin (hanyins)
- Gally Huang
- Jason Liu
- Kevin An


## Objectives and Background

### Goals and Benefits
- Make printing portable in the world where many other technology have already evolved to become more portable. <!-- Goals -->
- Current solutions using wireless connection usually support Bluetooth, which is short-range, or are expensive. <!-- Features -->
- The project allows for printing with a battery system and wireless uploading of image data, making it very portable. <!-- Functions / Benefits -->

### High Level Requirements <!-- 3/3 sentences: max of 3 sentences -->

- The device is able to process data correctly on its own through its hardware. 
- The device design is portable. It should be able to wirelessly and accurately get the user uploaded image data from a server to the embedded microcontroller. The device itself should also be completely powered by batteries, having an average battery life of ideally 2 or more hours. Last, it should sit as a small package, able to fit entirely in someone's hand for convenience.
- The device properly prints an image on to paper after it has processed the received data.


# Design

## Block Diagram
![Diagram](https://raw.githubusercontent.com/Jellyyz/ECE445/main/Proposal/445_proposal.drawio.png)

### Description

### WiFi Subsystem
##### WiFi Subsystem Overview:

The purpose of the WiFi subsystem is for the system to wirelessly connect between a server (can be locally hosted on a computer or on the cloud), a user, and the ESP8266 microcontroller. The benefits of this subsystem add portability for the product and a more “polished” feel for the user, reducing the need for excessive cables and clutter. 

There will be a simple webpage backed by the server that a user can interface with and upload an image to, and upon which the user can request a connected printer to print the uploaded image. The server will send data to the microcontroller through a wifi connection between the microcontroller to the server, in which the microcontroller further processes the data upon receiving it.

##### Subsystem Requirements:

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


##### Subsystem Requirements:

A Delite-10 FPGA will be utilized to simulate the operation of an ASIC which is not openly avaliable to the mass public. FPGAs are commonly used to test HDL code at a very cheap cost compared to a full scale tape out - albeit at a slower clock, so we will attempt to multiply our hardware throughput at the correct porportional speedup rate. The de-lite 10 can run at a speed of 50mhz, while mainstream ASICs can usually run 10 - 50x faster than this, but this still will be much faster than processing the image through software means (on the cloud or on the MCU). 

The fpga will take in 3 pixels and run it through a pipeline. Firstly the fpga must store all of the RGB values of an image into its on board memory in order to prepare it to processed. In this case, while the pixels are being stored into memory, we can start processing some of the data while it is still in the process of gathering data from the microcontroller. This is because many of the algorithms that will be applied such as Floyd-Steinberg dithering only requires 5 adjacent pixels for the image to start being processed. We need to set up a state machine that detects whenever a threshold amount of pixels have been loaded into the fpga and it will start to process this data simultanously. The third stage of the pipeline is when the data needs to be stored in a final bitmapped processed stage and then this final image will be sent back out into the microcontroller/wifi submodule and it will be ready for printing. This process happens super fast, and doing the math it should not take more than 3(pipeline stages) * (x * y) = 3xy, where x and y are the dimensions of the picture,  clock cycles in order to process a single image. 

Diagram:
![Diagram](https://raw.githubusercontent.com/Jellyyz/ECE445/main/Proposal/fpga_image_processing.drawio.png)

# Ethics and Safety

We believe that this design is quite safe since most of the components are found in everyday objects such as a phone and other consumer grade products. However, we take some ideas from prior consumer failures, such as the samsung s7 battery that exploded and imploded on itself due to a manufactoring defect. 

We should be testing the battery throughly in order to ensure that it is not causing for any power overages to occur as well as any harm to the user. This includes setting up battery current limitations as well as limitations on how much the battery can charge. By limiting the amount of things that the battery can do, this will in turn cause for the most voltile part of the system to be the most safe. 
