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
- The device design is portable, in that it is able to receive data through WiFi, is battery-powered, and is small.
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
