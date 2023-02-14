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
