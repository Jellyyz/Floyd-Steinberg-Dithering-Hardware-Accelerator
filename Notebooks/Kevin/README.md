# Lab Notebook

## Jan 18, 2023
Initial call with HP employees (Gally's coworkers) who are sponsors for the concept of the project. The project is proposed as an efficient and portable thermal printer, as well as ideas on algorithms we can implement through application specific digital hardware to assist in the printing process (or in our case, an FPGA since we don't have a large production volume requirement anyways).

## Jan 23, 2023
Meeting with groupmates Gally and Jason. GitHub repo is established, and begin planning/brainstorming high level ideas that we could turn to in addition to just the printer idea. Also discussed potential components we could use (microcontroller with built in WiFi chip, display, printer "guts", etc.). I proposed a classroom availability system on the Web Board earlier but a TA suggested that it was already a common idea, which steered us more towards the printer concept and we began to develop the RFA for it. Expectation is for us to have the RFA completed with the extra credit.

## Jan 25-26, 2023
Posted initial RFA for the portable printer on Web Board, received feedback from staff and improved certain aspects of design (complexity of PCB features, microcontroller integration, etc.). We reproposed the RFA, and got approval to move forward with the project. 

## Feb 3, 2023
Learned the basics of Django framework for application development through reading documentation and watching tutorials. Was able to create a basic local server that clients can connect to and make basic HTTP requests to, but definitely not a finished product by any means. Will need to get into this further for the WiFi subsystem as a whole, such as designing a frontend page, what a response will actually deliver to the MCU, etc.

## Feb 6, 2023
Wrote up the WiFi subsystem overview and requirements in preparation for the initial TA meeting and committed changes to the project proposal. 

## Feb 7, 2023
Met with TA Hanyin Shao, had our proposal (diagram, goals, etc.) reviewed for modification before the deadline. Arranged a weekly meeting time (4:20 pm every Tuesday), and went over general project deliverable requirements.

## Feb 9, 2023
Met with group to finish the proposal, including completing all the subsystems, revising the diagram, etc.

## Feb 11, 2023
Discussed components that need to be ordered when the my.ece order processing site is working again for the ECE 445 orders. The components have already been decided on, and we will have them ordered as soon as the issue with the site is fixed.

## Feb 14, 2023
Placed order for parts as listed on my.ece with new CFOP number:
- A 5 pack of SMT ESP8266 MCUs
- A 5 pack of ESP8266 development baords for prototyping/testing
- A 3 pack of USB to Micro-B cables

Order was approved on same day and will be shipped to the ECEB via Amazon so we may begin testing the microcontrollers before the end of this week. 

In addition, the group met with our TA to discuss areas for improvement on the proposal, which will also be necessary moving forward when creating the design document.  
## Feb 16, 2023
Group meeting to begin working on the Design Document and Team Contract. We went over the high level of what is expected for the documents, and added the documents in the Github repo. In addition, I brought up how the microcontroller might need to be used as a WebSocket client to the server, instead of an HTTP client, so it can receive async data on an event. This led to further discussion about even potentially changing the backend framework from Django to Flask to better optimize this, as Django applications may be better suited for a "heavier" project with a more diverse set of requirements than something like our project.

## Feb 19, 2023
After discussion and writing about the Team Contract with Gally and Jason, we finalized the document for submission and filled in everything required in the subsections, including signatures. Each person is to submit the document on their own in Canvas whenever before the deadline. We also worked on the Design Document, mainly filling in what was reasonable from the proposal and taking note for the components we needed to address/improve upon.

## Feb 21, 2023
Worked as a group on the Design Document again. One of the biggest concerns is about the Power Subsystem, as we are all relatively inexperienced when it comes to power electronics and batteries. We emailed Professor Gruev about meeting with him to discuss what's expected in the Power Subsystem, as well as components we may need to do further research on (regulators, boosters, etc.). We also signed up for a Design Review slot for the following Monday (2/27) @ 1:30 PM. 

## Feb 22, 2023
Met in person and held a Zoom meeting with Professor Gruev for a short Design Review, where we talked about the following:
- Ensuring pins between devices match the appropriate voltage on inputs, potentially needing level shifter circuits
- Functionality of the correct pins (ie. ensuring there were the right GPIO pins on the MCU for SPI)
- Type of battery to use in the Power Subsystem (specifically with Lithium-ion batteries with protection circuit as to not explode on overcharging/discharging)

We continue to work on the Design Document, with the majority of the Wireless, Board, and Imaging subsystems completed, in addition to the general components from the Proposal like the introduction. We still need to improve/write more in depth about the Power Subsystem, cost analysis, ethics/safety, and tolerance analysis sections.

## Feb 23, 2023
Met with group again to finalize the Design Document. Here, we finished the incompleted sections from the previous meeting listed above and rechecked the RV tables. Submitted the Design Document to the PACE website.

## Feb 24, 2023
Cleaned the Team Contract up a bit stylistically and submitted to Canvas.

## Feb 26, 2023
Met with group in preparation for the Design Review on 2/27, and also discussed changes needed for the current Design Document (ie. about usage of LDO's to step down voltage for anything that requires 3.3V Vin, adding in a visual diagram for the FPGA state machine, datasheet-specific limits on the LDO's, etc.). 

I also decided to implement a clone of the current Django server but with Flask framework from scratch just to see what it is like (because of the discussion from 2/16). It ended up being a lot more straightforward than the Django framework because it is very lightweight and barebones. Designing a system that allows a user connected to the host URL to upload files to the local server is actually more "understandable" and better to debug from the ground up with Flask at least, although it doesn't come with all the fancy admin/database/authentication stuff that a newly made Django app comes with. In addition to starting on the backend, I worked on the HTML/CSS styling of the frontend so users can upload when connected to the server. The next step to the server is implementing a WebSocket that can deliver data upon the user form POST request to the MCU client, and writing the MCU code for it to be a WebSocket client, which is dependent on us testing with the actual MCUs (still in delivery according to my.ece, strangely enough). <br>

Frontend samples made with HTML/CSS shown below:
![image](https://user-images.githubusercontent.com/61933430/236158367-0862fb1a-ebba-4399-8b52-a0c21d4b7a11.png)
![image](https://user-images.githubusercontent.com/61933430/236158790-2c2f7f2d-791e-47ac-ac1e-d55a2b4c6012.png)


## Feb 27, 2023
Had design review. Pretty self explanatory, where we discussed our design in front of Hanyin, some peers, and Professor Gruev and answered questions related to our design choices. I think it went pretty well, we covered all the important aspects of our design within the time limit and everyone got a chance to speak.

## Feb 28, 2023
Had weekly meeting with Hanyin where we just discussed progress and comments from the design review. Also arranged meeting with group to meet on Thursday. 

## Mar 2, 2023
Have a good version of the server with a flask socket running on one of the page routes, so when a client connects and listens in on the socket they can receive all the events. I used jQuery to kind of vizualize the events being received for the listening clients for now so they can see stuff like the uploaded images, broadcasted messages, etc. This will probably have to be removed though because I don't think the microcontroller will see the data the same way, and it has to connect to the socket itself which is embedded in the html page itself, and if it is removed then we need to figure out a more "robust" and definitive way for the server to connect to the microcontroller after someone uploads an image.

## Mar 4, 2023
Meeting at ECEB with group. I tried playing around with the ESP-12F development board just to see what I could do with it, since we will be programming the MCU on its own later on our own PCB. After installing all the packages and libraries for the ESP8266 module I could get it to connect to WiFi at least, which is a good start. I also tried getting it to connect to the server socket as a client using several different ways, but nothing really worked I guess which is unfortunate and I do think we need to find a fix somehow. Next meeting will probably involve trying to find a fix or alternative solution that still enables transmission of data over WiFi (ie. barebones TCP?).

## Mar 7, 2023 
Weekly meeting with group and Hanyin again. Afterwards the group went to one of the ECEB classrooms to work and I tried to fix issues with the MCU because it still doesn't hold a consistent connection to the websocket. Basically it connects then disconnects before anything happens, which isn't long enough to actually receive any event from the server. Meeting on Thursday after this.

## Mar 9, 2023
Met with group again to talk about SPI between MCU and FPGA. We identified the signals that interface between the two, the way we feed the serial data in and where they go, and how we will be using the memory on the FPGA. In addition, we worked on our assigned work as usual, and still having trouble with the WebSocket approach. I'm starting to read about creating a TCP connection to the MCU, which allows the server to still send data over to the MCU client without the client having to make a request for data (ie. it still listens for data). This would probably be a good fix just because it's more "barebones" than trying to deal with a WebSocket, which uses TCP anyways.

## Mar 11, 2023
Placed order for parts again since first order didn't go through (?) consisting of:
- The ESP8266 ESP-12F SMD MCUs.
- Bunch of SMD solder components (LEDs, resistors, capacitors, Zener diodes, Shottky diodes, USB-C PD chip).
- Jumper wires for prototyping.
- USB to TTL serial converter cable.

## Mar 15, 2023
Implemented a TCP host connection for the MCU to connect to at upload for an image. Basically, when a user uploads an image the server stores the image, and then using threading it launches another process for establishing a TCP connection to the MCU, which the MCU can connect to through some pretty simple TCP C functions. This process sends in byte (base64 encoded) data to the MCU, and because TCP is a reliable sending protocol the MCU will (theoretically) receive all the data. Once the data has all been transmitted, the server closes the connection until someone else uploads an image again, in which case (assuming the MCU is currently idling and waiting on the server to establish the TCP connection with it) we repeat this process.
So far, can send pretty big base64 encoded sequences of data, and the sizes of bytes sent and received match, but the serial monitor on the Arduino IDE prints out funny characters sometimes like backward question marks. Will need to look into this issue more later on, but I'm assuming the data is all there still?

![progressreport-Page-2 drawio](https://user-images.githubusercontent.com/61933430/236315980-dad62df2-60a8-47d1-8704-55aa97da6375.png)
<br> Flow chart diagram for server control

## Mar 19, 2023
I believe the strange characters in the USB serial monitor are showing up because of the baud rate of the monitor. When sending the characters back to the server via TCP to print out to console and verify by eyeballing, it seems like they are all the same so I will assume the data is all correct when received at the microcontroller at the byte level. Online forums also state that it's likely an issue with the speed of the data received and displayed in the serial monitor through the MCU.


## Mar 27-29, 2023
Spent this period working on the individual progress report. Wrote up the introduction, design sections, citations, self assessment, and made diagrams for the wireless subsystem. Had to perform additional RV for the existing wireless subsystem test setup to "prove" that the subsystem functions as necessary, filling in the RV table for user to server upload times. In addition, I calculated the probability that a 10 MB image could be uploaded within the 5s time on IllinoisNet WiFi, given that up to 15 other users are connected to the WiFi network and uploading/downloading their own data at the same time. This should give enough "confidence" that the wireless subsystem will perform as intended, and has a high tolerance to potential congestion in the IllinoisNet WiFi.

<img width="553" alt="image" src="https://user-images.githubusercontent.com/61933430/236316946-64c867ef-67b1-4438-a214-bc190a2766e4.png">
Upper bound binomial distribution model as described in progress report, just for uploading a 10MB image to the server on IllinoisNet

## Mar 30, 2023
Picked up the PCB and began soldering components. One issue that occurred is that Gally and Jason, upon testing the printer, found out that the ESP8266 has weird "pulses" on the pins we intended to use, and this is a problem because we are dealing with digital hardware that relies on the correctness of the input signals (FPGA and printer), especially at startup. We realize this is an issue with the MCU, and we need to find a way to get around this (may just have to replace the MCU entirely if everything fails because this pin behavior is listed in its documentation and there's not a lot of other pins we can easily swap with).

## Apr 1, 2023
Email sent to Hanyin about the weird ESP8266 issue, but on that note we will probably have to switch to another MCU like the ESP32 or something that has a lot more flexibility (more GPIO pins that are held constant at startup). This switch means our current PCB is also going to be useless, because it's fitted for an ESP8266-12F and the ESP32 has a much bigger footprint, and will set us back another week so if we need a new PCB. The current PCB still hasn't been tested because the ESP8266 probably can't be the long term option anymore because of the weird pin behavior at startup. 

## Apr 3, 2023
Received the ESP32 dev board from Gally. Started doing basic programming with it just to see how it works, but so far a lot of functionality seems pretty similar to the ESP8266, like connecting to WiFi. Will see more later, but this is likely the MCU we have to stick with for now as Jason is testing with it.

## Apr 4, 2023
Had meeting with Jason and Hanyin about the issue with the ESP8266 MCU we used before. Talked about clock gating the glitchy pins with stable ones at startup, which is more feasible with the amount of pins on the ESP32, as well as about potential techniques we could use as a last ditch attempt if everything else fails, such as only allowing the system to start up after a certain time period, or reducing the effect that noise (ie. from clock gating) can have in our system using something called a Schmitt Trigger circuit since we are using sensitive hardware.

## Apr 7, 2023
Order placed for more SMD circuit components and the new ESP32 MCUs (also SMD components for our PCB). Small LCDs with the SSD1306 chip also ordered, so just need to wait until they come in to continue working and testing. Also the new PCB order was placed, so we have to wait on that to actually start soldering again, as well.

## Apr 11, 2023
Received the black/white LCD from Amazon which uses I2C protocol. Lots of tutorials online entail how to "draw" on the display, and also there are some libraries that allow us to draw bitmaps on the display as well. So far have the display for battery level and status showing without issues, and the code can be integrated pretty easily (call function for "redrawing" display every so often to update screen for user).

## Apr 14, 2023
Started soldering components onto new PCB Gally ordered. This process took several hours, including manually hand soldering, learning how to use the stencil and baking the PCB with the reflow oven (for the buck converter and ESP32 MCU). Also had to create a ~41 kOhm resistor out of some film resistors in the drawers because we didn't have the SMD component for it. Anyways, we had to adjust the PCB a bit because the 5V connection we have to the ADC pin on the MCU for reading is too high, and anything above 3.3V according to the documentation will kill the pin and potentially the MCU itself so we just broke the connection between the MCU and power subsystem part by crushing the SMD resistors in between them. 
Trying to program the ESP32 on the PCB now directly using a USB-TTL programmer. We follow a simple schematic as follows through the tutorial at https://techtutorialsx.com/2017/06/05/esp-wroom-32-uploading-a-program-with-arduino-ide/: 
![alt text](https://i0.wp.com/techtutorialsx.com/wp-content/uploads/2017/05/esp-wroom-32-programming-circuit.png)<br>
So far it does not work for more than 1 upload of code, every other attempt the Arduino IDE says something about an "Invalid head of packet" for some reason. Will figure it out tomorrow

## Apr 15, 2023
After much guessing and checking, the ESP32 on the PCB can be programmed, but in a very specific order as follows:
- Power off/unplug the MCU from the USB TTL programmer, then plug it back in
- Make sure IO0 is connected to ground
- Upload the code to the MCU like normal, the chip should be in boot mode and accept a program flash
- Unplug the IO0 connection to ground (this part is important for the chip to run the actual code)
- Power off/unplug the MCU from the USB TTL programmer, and plug it back in. As it powers on, it should run the code just like the dev board does, like connecting to WiFi.

This is important for the project because once Jason completes the SPI controller we can proceed with flashing the code to the MCU and integrating all the systems together for the demo.<br>
![image](https://user-images.githubusercontent.com/61933430/236138135-1efe1641-0196-4170-ac63-91720d48d2c5.png)<br>
The first code I got to run on the PCB embedded ESP32.

## Apr 17, 2023
Tested the power regulator circuit of the Power Subsystem today using a power generator machine in the lab. With the voltage set to 7.4V, plugged into the Vin of the application circuit, we were able to read a constant output voltage of 5V within +- .01, which is a great sign that this system works as specified. We also tested it on a range of voltages from the power supply between 7-8V and the output voltage hardly changed at all, as expected according to documentation but was pretty cool to see actually working. Will test with the actual lipo batteries later, hopefully it works. <br>
Also had mock demo today, where we showed Hanyin our progress thus far. Demonstrated that the power regulator could output a constant 5V DC, and that we could power the FPGA directly using this now, instead of plugging it in via USB to a computer or USB wall adapter. Also Jason demonstrated the Flask web server again and how it can interact with the MCU to print an image out, although without hardware acceleration so far but we are close to getting the MCU working all good with the FPGA.

## Apr 18, 2023
Just tested the battery a lot to make sure the voltage doesn't jump or anything when plugged into something, so it seems fine. It is still at 7.4V, just like when we got it initially, and after plugging it into the buck converter circuit, the output is a steady 5V as expected, and it turns the FPGA on without any problems! <br>
![image](https://user-images.githubusercontent.com/61933430/236161290-df44080c-4e3f-4127-954a-d8181fe8c6b6.png) <br>
This is all I have to verify for now on the Power Subsystem. Just need to design the 3D CAD printer container, which shouldn't be too bad.

## Apr 21, 2023
Have a simple CAD design ready and can submit a print job to a 3D printing lab on campus, but the problem is that these places all estimate at least $30 to print the design, which is kind of expensive for something that just holds all our components anyways and goes beyond budget. The CAD model looks like this: <br>
![image](https://user-images.githubusercontent.com/61933430/236145626-11583d13-49e9-4670-a94d-81e5ee36ec64.png) <br>
Just the base, walls, and lid, and has some "strategically placed" holes for allowing paper and charging cables to feed in through. Will look for alternatives that are free or < $30, at least.

## Apr 22, 2023
Found a place on campus that allows for free printing but apparently you need to be an art student to use it. A machine called the "Zortrax M200 plus", where they do the free printing only if you CAD and slice a model already in something called a "zcodex2" type file. I will have to learn how to actually do this, since I thought it would just be submitting the stl files and calling it a day.

## Apr 23, 2023
Had to install some software called the "Zortrax Z-Suite" to create the zcodex2 file, and uploaded the pre-existing stl file and had to do a bunch of things for slicing the design like specify infill %, which I guess is the density of the filling of the printed parts, and the nozzle diameter at .4 mm, and the pattern of the fill. You can read about it here: https://art.illinois.edu/about/resources-for-current-students/facilities/digital-labs/tutorials-templates/tutorial-preparing-3d-print-files-for-the-zortrax-printers/.
Also Gally said he found someone who could submit the print job and we can hopefully get it before the demo, but otherwise we'll have to demo in the reused tin container that the printer already lives in.

## Apr 25, 2023
Final push to get the project all together. According to the person who submitted the print job, it just got out of the queue and started printing (at night), so we probably won't get it in time for the demo since the estimated print job time was at least 1 day according to the Z-Suite software. Jason and Gally have the FPGA and MCU working together now, so we need to put the dev board code on the PCB MCU and run everything off the power subsystem. <br>

Gally and Jason were able to make slight last minute debugging modifications in some code and now we have the completed "final" product, which is the functional wireless and battery powered printer that uses the programmed embedded MCU for system control and the FPGA for hardware dithering. Only issue is the 3D printed box still for presentational purposes, but at least our demo will work, also I killed my laptop on accident when working on additional features which sucks a lot. I will elaborate when I don't feel as bad about it later.

* Update:
Okay so here's the laptop killed story: when trying to create a voltage divider to read battery level from the ESP32's ADC pin (on a dev board for testing), I had the 3.3 V line and ground on the MCU plugged into the breadboard + and - rails, and after finding (what I hope were) satisfactory mappings for the ADC readings to battery voltage levels and testing using the 3.3 V line just to be safe (since the ADC pin will fry if connected to anything above 3.3 V), I accidentally plugged the 8V lipo battery into the same 3.3 V and ground line from the MCU because I blanked that something was already plugged into the + - rails. Anyways, right after this happened my laptop turned off and the blue MCU LED turned off and the metal lid on the chip got hot, so that means I definitely fried it. Also my laptop wouldn't turn on and I had to get a friend to open the thing so I could drain the battery and all the power in the laptop apparently, and it turned back on but it seemed like my code didn't save. I did some research about this and apparently this happened when connecting the battery in parallel to the 3.3V line, and on the dev board we used there is no backward current protection and this was connected directly to my USB V+ and GND line. From what I read, when a battery is in parallel it'll try to discharge current until the voltages are balanced, but this is bad because I think this current went straight back into my laptop and it just died, all in under 1 second. Apparently only "high end" MCUs have isolated voltage lines or something, but either way this caused a lot of stress and wasted half a day's worth of progress of additional features. This also ruined the battery, because now it just starts smoking (concerning) when we try to plug it into anything like a simple voltage divider, and it can't be charged anymore since the default charger LED indicates that it's fully charged (also concerning), so now our theoretical maximum energy capacity is safely halved from 4000mAh to 2000mAh since we were planning on connecting the 2 battery packs in parallel to have longer battery life. Anyways, end of rant, moral of the story: triple check every connection you have in a breadboard or circuit before sticking something new in, be extra careful when dealing with something like a battery (especially one capable of high discharge rate), and it's probably best to unpower/unplug every important expensive connection beforehand. <br>

* Update again:
The 3D printed parts came in, but it's 5 days after the demo now as of typing this. They look cool I guess, but it's a bit late unfortunately. You get what you pay for. <br>
![image](https://cdn.discordapp.com/attachments/1070173249180287072/1102695654289063936/20230501_153825.png)


