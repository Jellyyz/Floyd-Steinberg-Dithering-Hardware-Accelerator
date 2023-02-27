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

I also decided to implement a clone of the current Django server but with Flask framework from scratch just to see what it is like (because of the discussion from 2/16). It ended up being a lot more straightforward than the Django framework because it is very lightweight and barebones. Designing a system that allows a user connected to the host URL to upload files to the local server is actually more "understandable" and better to debug from the ground up with Flask at least, although it doesn't come with all the fancy admin/database/authentication stuff that a newly made Django app comes with. In addition to starting on the backend, I worked on the HTML/CSS styling of the frontend so users can upload when connected to the server. The next step to the server is implementing a WebSocket that can deliver data upon the user form POST request to the MCU client, and writing the MCU code for it to be a WebSocket client, which is dependent on us testing with the actual MCUs (still in delivery according to my.ece, strangely enough).
