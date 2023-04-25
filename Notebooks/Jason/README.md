# Lab Notebook

## Jan. 24 - 25, 2023
By working on the RFA, we did a lot of brainstorming and searching for specific parts to consider.
LCDs and displays on Adafruit seemed quite promising because of their compactness, low price, and available library
for programming the display in C/C++. There were other displays that had more constrained dimensions like 
the Hitachi HD44780 LCD that Gally brought up. 

## Feb. 7, 2023 (20 minute TA meeting)
We met up for the first weekly TA meeting with Hanyin. We will be meeting weekly on Tuesdays at 4:20 PM to 4:40 PM.
We are preparing to get our important components (FPGA, MCU) so we can start basic testing. 

## Feb. 8, 2023
The proposal is being worked on - we have a good general idea of the system and what each block should do. We received
a DE2 FPGA board in our locker. We eventually finish the proposal on a markdown file. Comparing it to other proposals uploaded,
I wonder if there was a template?

## Feb. 11, 2023
I start drawing up a schematic of the Board System (i.e., the main component is the ESP8266 with debugging tools like 
buttons/switches to reset, LEDs that turn on in response to something, etc.).

## Feb. 12, 2023
The web server I'm experimenting with is as such:

Any device that is on the same network as the host can access this server / site.
Any device that can access this server / site can upload an image via a generic form for selecting image files
(i.e., on your PC, it will launch the file system; on your phone, it will launch the photos library).
Once uploaded, that server saves that image to local storage (i.e., on the host's file system).
Any device can see images in local storage if we statically embed them in our front end (html template).

Basically, some GET / POST request handlers are implemented for the image form for uploading images.
Not sure about fetching images from the local storage with a separate request though.

Basics to developing the Django project:
1. Clone it with Git.
2. Create your own virtual environment somewhere on your local PC. First, you need to install 'virtualenv' with pip.
3. Then, create a virtual environment 'venv'.
4. Activate 'venv'.
5. Go to the Git project root directory and install the requirements (i.e., pip install -r requirements.txt) for the project.
6. Go to the Django project directory and run the server with 'python manage.py runserver 0.0.0.0:8000'. This will run the 
server on '{host's IP address}:8000/'. Any device on the same network should be able to access this server.
6.1. Make sure your firewall allows access for devices over the network (or another option is just disable it).
6.2. Make sure you're on a valid url (defined in multiple 'urls.py' in each app/project directory).
6.3. Make sure that forms are working, as well as static media data. I've included basic debugging visuals for the 'upload' app.
7. Ctrl+C the terminal that is displaying the server information to quit the server.
8. When pushing Django project files to source control, don't include the virtual environment, media files 
(but static files are fine), and private information you write in 'settings.py' (e.g., your private key, allowed hosts that may include IP addresses).

We could most likely write up a simple Python or Batch file to handle most of these steps.

## Feb. 13, 2023
I continue drawing the schematic. I've learned some neat tricks (at least, I think they're neat).

For aligning symbols on your schematic, you can press 'Space' to set an anchor point. Then, near the bottom of the
schematic window, there should be a column in the status bar that says 'dx: ... dy: ...'. These are the difference 
between your cursor and the anchor point. You'll want 'dx: 0' or 'dy: 0' to align symbols.

I tried playing around with the server again. Didn't really make much progress, but I've compiled most of the basics 
in the previous day's entry.

## Feb. 14, 2023 (20 minute TA meeting at 4:20 PM)
Essentially, we can handle POST requests (i.e., processing our data to the server), but our GET requests are not quite there yet (i.e., fetching data from the server). We may be able to test the GET requests in JavaScript or maybe even in the Django project. We'll have to do some digging.

For our TA meeting, we need to modify our proposal and fit it to the design document. 

## Feb. 15, 2023 
Users can send a 'GET' request to the server to fetch the most recently uploaded image. For now, I tested with my PC hosting the server and my phone making this specific 'GET' request on the same network. The template page updated to embed the most recently uploaded image on the phone's display. If the PC uploads another image, the phone can send another request to update its display (and vice-versa). We will probably do something similar with the ESP8266 - it will send a 'GET' request to one of our urls, which has a request handler which will send this most recently uploaded image as context (maybe convert it to a suitable format in Python as well?).

## Feb. 16, 2023
We had a virtual meeting where we discussed roles and what to do going forward. We may be able to experiment with our components by early next week.

## Feb. 17, 2023
We are starting the Team Contract and Design Document and need to carefully go through them to determine our project's trajectory going forward.

## Feb. 20 - 22, 2023
Battery discussion with Gruev on Zoom while at Beckman Institute. The general advice we got was to purchase trusted batteries (e.g., from this company called Tenergy). Mainly, we want batteries with ICs and protective casing because we're not well-versed on power topics.  

## Feb. 23, 2023
We finished the Design Document remotely (Discord meeting to go over it and finish it up).

## Feb. 25, 2023
We received the ESP8266 development boards. That means we can start programming basic tests on it through Arduino IDE.

## Feb. 26, 2023
I managed to set up the ESP8266 by downloading the appropriate requirements (Arduino IDE, various libraries, CH340 driver, other drivers) and program the ESP8266 to scan nearby networks. I also managed to get it to connect to a 2.4 GHz nearby network given I know its name and password.

## Feb. 27, 2023
Today, we did the Design Review presentation. I did not do the Peer Review assignment yet.

## Feb. 28, 2023
We met again in a study room on the 2nd floor of ECEB. We receive the thermal printer, and during the meeting, I attend a peer review session.

## March 2, 2023
Since the Design Document is due soon, we meet at Beckman Institute to work on the Design Document.

## March 4, 2023
There was a meeting at ECEB's 1st floor (those large tables next to the auditorium).
There, I looked into dithering given a base64 string describing it. There are many potentially useful libraries and functions for doing so. Promising ones are Apple's base64 string encoding/decoding functions, LodePNG for handling PNG data, LibPNG for the same purpose, and more. 

## March 5, 2023
C++ software implementation on MCU is finished.

We can dither an image on the MCU with these new functions with LodePNG libraries (used to encode bytes describing the PNG file to actual RGB bytes).

## March 7, 2023
We met after the 20 minute TA meeting on the 3rd floor of Beckman Institute.
The goal is to try to fix the server and start SPI work for communication between the MCU and FPGA.

## March 9, 2023
Meeting at Beckman Institute at 6 PM<br>
  Kevin : Server<br>
  Gally : Parts to buy, etc.<br>
  Jason : SPI controller<br>

Slave diagram drawn at Beckman Institute:

![image](https://github.com/Jellyyz/ECE445/blob/main/Notebooks/Jason/Slave.jpg)

## March 10, 2023
I read through some SPI basics and example programs.

## March 11, 2023
I wrote up a basic SPI test program that sends a vector of data out the SPI pins.

## March 12, 2023
Didn't code anything... read a little bit about SPI. We send and receive at the same time. Since we must process the sent byte, the two "send and receive pointers" may be disjoint.

## March 13, 2023
SPI advanced... for a given buffer, transfer them from MCU to FPGA and also get the new buffer where each old byte b is now mapped to f(b), where f is processing function(s) performed on the FPGA. Want to minimize the number of SPI_CLK cycles but first, we want correctness... don't want to infinitely loop() either - want to know for sure when we're done so the MCU is in total control over the system. Idea: have the FPGA raise a signal when a byte is ready to be sent to the MCU. This signal is checked before each SPI transfer when the SS is HIGH (but SPI is still going on), which has the MCU store the received byte in the next position (received pointer points to this) of the array/vector/buffer. On falling edge of SS, FPGA lowers the signal. Or maybe there's a simpler solution.

Worked on imaging HDL and expanding the SPI program right now.

## March 15, 2023
Worked on server -> MCU -> server testing to visualize images.

## March 16, 2023
Finished a working version of server -> MCU -> server testing with small images only because of memory constraints on ESP8266 (can see image on server).

## March 20, 2023
Today, we met on Discord at around 9:15 PM to discuss the progress on the project. Namely, we made sure that we understand the Floyd-Steinberg dithering algorithm on the bytes and how it's implemented in the FPGA project files so far.

## March 24, 2023
We compared the hardware dithering (simulation on TestBench) to the software implementation dithering output. I implemented reading in the input to the TestBench and reading out the output. 

Namely, the input to the software implementation is 16 by 16 buffer of bytes:

![image](https://github.com/Jellyyz/Floyd-Steinberg-Dithering-Hardware-Accelerator/blob/main/Notebooks/Jason/input_bytes.PNG)

And the output I got was:

![image](https://github.com/Jellyyz/Floyd-Steinberg-Dithering-Hardware-Accelerator/blob/main/Notebooks/Jason/sw_output.PNG)

## March 25 - 27, 2023
The Individual Progress Report is due pretty soon. While writing it up, I (softly) verified a requirement in our Design Document. Specifically, the hardware accelerator (FPGA) should fully dither an image faster than software implementation (MCU). 

![image](https://github.com/Jellyyz/Floyd-Steinberg-Dithering-Hardware-Accelerator/blob/main/Notebooks/Jason/individual_report_snippet.PNG)

## March 28, 2023
There was a meeting today. Afterward, we received a batch of PCBs and new parts. We went through all the parts one-by-one to confirm if we received everything.

## March 30 - 31, 2023
We met in lab today to formally test out the thermal printer's functions. We use a power supply at around 7.5V in the lab. After playing around with it, some helpful conclusions we made were: plug TX pin of printer to RX pin of MCU and RX pin of printer to TX pin of MCU. Also, our thermal printer expects a serial communication at 9600 baud rate (important). We only managed to successfully print out a test page once out of multiple attempts through programming the MCU. The test page should look like this:

![image](https://github.com/Jellyyz/ECE445/blob/main/Notebooks/Jason/test_page.jpg)

## April 2, 2023
We received ESP32 development boards. This board is more popular (because it has more pins, has lots of Python users, has more memory) than the ESP8266, I would say. 

With this board, storing the image data is more manageable. Previously, we had around 40 kilobytes to store dynamic variables. Now, with the ESP32, we have a little under 300 kilobytes. This implies that we might be able to store a 512px by 512px image on the MCU if there's sufficient contiguous memory.

## April 4 - 5, 2023
I managed to print out an image with the ESP32 after receiving data from our server. Namely, I started the server up and then uploaded this image:

![image](https://github.com/Jellyyz/ECE445/blob/main/Notebooks/Jason/Gunjou.png)

Then, the MCU polls for the image, receives the grayscale bytes, and then performs a conversion to black-white bitmap vector. Then, the MCU starts a connection to the printer and sends the data via RX/TX pins. The resulting printout I got was:

![image](https://github.com/Jellyyz/ECE445/blob/main/Notebooks/Jason/Gunjou_printout.jpg)

By observation, the printout resembles the input image to a degree.

Something I might want to do is code the server to send out the bitmap instead of grayscale bytes to see the resemblance.

## April 10, 2023
SPI protocol seems to work both directions. Specifically, the MCU can send a byte buffer of length some power of 2 to the FPGA (the toy example uses 8 bytes), which stores it to SRAM. Then, the FPGA performs an arbitrary function on the received bytes (i.e., increment the bytes) and then signals that the MCU should pull for the data now. The MCU, who was waiting for this signal, now begins a new buffer transfer by first sending a dummy byte to "align" the FPGA side. Then, a buffer is transferred, which stores to the MCU side. I have verified that the FPGA receives the correct data by reading the values on the hexadecimal displays. I have also verified that the MCU receives the processed bytes by reading the buffer out to the console.

I also ordered the batteries today on My.ECE that cost around $23.99 without tax.

## April 11, 2023
SPI protocol seems to be repeatable. There is one unexpected behavior, which is the last byte is rewritten to in memory. But this happens after the MCU receives all the bytes already, so we don't care about this "bug".

This is exactly one week from mock demos. 

We met shortly... for meeting. We discussed the exchange between the MCU and FPGA at a high level as follows:

![img](https://github.com/Jellyyz/Floyd-Steinberg-Dithering-Hardware-Accelerator/blob/main/Notebooks/Jason/spi.jpg)

The basic test I have to formulate is to have the MCU receive image data (that is already either black or white) from the server, send all of these bytes to the FPGA, have the FPGA store all of these bytes to SRAM, output the bytes from the FPGA's SRAM out back to the MCU, have the MCU convert the image bytes to a bitmap, and finally, make the MCU transfer the bitmap out to the thermal printer while starting the printer protocols. 

## April 12 - 14, 2023
The basic test works in general (for large images, you can make out what it is). For the image

![img](https://github.com/Jellyyz/Floyd-Steinberg-Dithering-Hardware-Accelerator/blob/main/print_as_is_sys/team29.png)

I managed to print it out by uploading it to the server, which sends it to the MCU.
The MCU sends the received stream to the FPGA via SPI, where the FPGA stores it to SRAM. 
Then, the FPGA outputs everything stored in SRAM back out to the MCU.
The MCU stores this data and then creates the bitmap based on this data.
Finally, the MCU begins printing operation.

This is sample printout (note that the black printouts are outputs after changing the program to try to improve it... it did not work, as you can see).

![img](https://github.com/Jellyyz/Floyd-Steinberg-Dithering-Hardware-Accelerator/blob/main/Notebooks/Jason/print_test.jpg)

As you can see, minute details like single pixels can be seen on the paper if you look carefully. This test uses a power supply plugged in to the wall at 7.5 V. The brightness of the printed output is decent but sometimes a bit too light (such as the images to the right of the above image).

Here is an annotated version of the image to visually explain the different outputs:

![img](https://github.com/Jellyyz/Floyd-Steinberg-Dithering-Hardware-Accelerator/blob/main/Notebooks/Jason/print_test_annotated.jpg)

## April 15, 2023 
I have added a new function to the current SPI controller. Namely, we can program the MCU to send a signal to the FPGA to asynchronously "reset" (i.e., set signals/variables to what they are defaulted as), which may be useful if the FPGA thinks that it's still receiving bytes when it isn't (we can end the receiving process when the memory addresses "lap" or "loop" and then wait for the asynchronous reset). However, I have not tested this yet. I will test this next week and then try to implement the SPI controller with the dithering algorithm modules.

## April 16 - 21, 2023
The system loops for the most part (I've witnessed it fail one time out of probably hundreds of times). Also, I've modified the FPGA's dithering algorithm so that output images aren't inverted (they were inverted previously for some reason).

## April 22 - 23, 2023
I modified a lot of logic on MCU side (bitmap formation, server communication, and packet-like protocol) and FPGA side (dithering algorithm conditionals, packet-like protocol) so that any image (with the proper extension) uploaded to the server can be printed (at least, to my knowledge) regardless of size. We bounded the total image size within 66536 pixels because the FPGA memory is bounded to this amount. Therefore, any image above this size is approximately resized to this boundary and then printed. 

## April 25, 2023
We are meeting for the final time before the final demo tomorrow. 
