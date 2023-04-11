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

## Feb. 20-22, 2023
Battery discussion with Gruev on Zoom in that one place next to ECEB 

## Feb. 23, 2023
Design document finish remote

## Feb. 25, 2023
Got ESP dev boards...

## Feb. 26, 2023
Programmed ESP to scan/connect/get request

## Feb. 27, 2023
Design review...

## Feb. 28, 2023
Meeting... updating on progress... meeting next.

## March 2,2023
Meeting at fancy place for document or something I believe

## March 4, 2023
Meeting at ECEB 1st floor => C imp. progress

## March 5, 2023
C imp. on MCU

## March 7, 2023
Meeting after TA on 3rd floor => Trying to fix server and start SPI work

## March 9, 2023
Meeting at fancy place at 6 PM
  Kevin : Server
  Gally : Parts to buy
  Jason : SPI

Slave

![image](https://github.com/Jellyyz/ECE445/blob/main/Notebooks/Jason/Slave.jpg)

## March 10, 2023
SPI basics...

## March 11, 2023
SPI basics...

## March 12, 2023
Didn't code anything... read a little bit about SPI. We send and receive at the same time. Since we must process the sent byte, the two "send and receive pointers" may be disjoint.

## March 13, 2023
SPI advanced... for a given buffer, transfer them from MCU to FPGA and also get the new buffer where each old byte b is now mapped to f(b), where f is processing function(s) performed on the FPGA. Want to minimize the number of SPI_CLK cycles but first, we want correctness... don't want to infinitely loop() either - want to know for sure when we're done so the MCU is in total control over the system. Idea: have the FPGA raise a signal when a byte is ready to be sent to the MCU. This signal is checked before each SPI transfer when the SS is HIGH (but SPI is still going on), which has the MCU store the received byte in the next position (received pointer points to this) of the array/vector/buffer. On falling edge of SS, FPGA lowers the signal. Or maybe there's a simpler solution.

Worked on imaging HDL, expanding SPI

## March 15, 2023
Worked on server -> MCU -> server testing

## March 16, 2023
Finished a working version of server -> MCU -> server testing with small imgs only (can see image on server)

## April 10, 2023
SPI protocol seems to work both directions. Specifically, the MCU can send a byte buffer of length some power of 2 to the FPGA (the toy example uses 8 bytes), which stores it to SRAM. Then, the FPGA performs an arbitrary function on the received bytes (i.e., increment the bytes) and then signals that the MCU should pull for the data now. The MCU, who was waiting for this signal, now begins a new buffer transfer by first sending a dummy byte to "align" the FPGA side. Then, a buffer is transferred, which stores to the MCU side. I have verified that the FPGA receives the correct data by reading the values on the hexadecimal displays. I have also verified that the MCU receives the processed bytes by reading the buffer out to the console.

## April 11, 2023
SPI protocol seems to be repeatable. There is one unexpected behavior, which is the last byte is rewritten to in memory. But this happens after the MCU receives all the bytes already, so we don't care about this "bug".

This is exactly one week from mock demos. 

We met shortly... for meeting.
