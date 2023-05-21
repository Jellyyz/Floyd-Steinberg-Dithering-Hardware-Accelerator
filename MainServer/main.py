from flask import Flask, session, request, render_template, flash, url_for, redirect
from werkzeug.utils import secure_filename
import numpy
import base64
from PIL import Image, ImageEnhance
import random, socket, threading
import os
import math
import time

UPLOAD_FOLDER = './static'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.secret_key = 'dog'


#tcp server
TCP_IP = '0.0.0.0'
TCP_PORT = 8585

def launchServer(args):
    image = Image.open(UPLOAD_FOLDER + "/" + args).convert("L")
    image.save(UPLOAD_FOLDER + "/" + "expected_grey.png")
    enhancer = ImageEnhance.Contrast(image)
    #image = enhancer.enhance(1.5)
    image.save(UPLOAD_FOLDER + "/" + "expected_big.png")
    
    data = numpy.asarray(image)
    h, w = data.shape
    # start expmt.
    new_h = h
    new_w = w
    target = 66536
    if h * w > target:

        aspect = w / h

        if aspect > 1:
            low = 0
            high = 384
            new_w = 0
            while low <= high:
                mid = int((low + high) / 2)
                new_h = int(mid / aspect)
                
                new_size = mid * new_h
                
                if new_size < target:
                    new_w = mid
                    low = mid + 1
                else:
                    high = mid - 1
            new_h = int(new_w / aspect)
        else:
            low = 0
            high = h
            new_h = 0
            while low <= high:
                mid = int((low + high) / 2)
                new_w = int(mid * aspect)
                
                new_size = mid * new_w
                
                if new_size < target:
                    new_h = mid
                    low = mid + 1
                else:
                    high = mid - 1
            new_w = int(new_h * aspect)
        
        image = image.resize((new_w, new_h), Image.LANCZOS)
        image.save(UPLOAD_FOLDER + "/" + "expected_small.png")

        data = numpy.asarray(image)
        true_h, true_w = data.shape
        assert(true_h == new_h and true_w == new_w)
    # end expmt.
    WIDTH = 384 # said straight up from the printer documentation
    skip = math.ceil(w / WIDTH)
    # format:
    # assume w and h are 16-bit integers w[15:0]
    # then,
    # img_as_bytes = {
    #   w[15:8], w[7:0],
    #   h[15:8], h[7:0],
    #   data[]
    # } 
    w_bytes = new_w.to_bytes(2, 'big')
    h_bytes = new_h.to_bytes(2, 'big')
    img_as_bytes = w_bytes + h_bytes + data.tobytes() # img_as_bytes contains new numpy -> bytes array for downscaled image
    #print(img_as_bytes)
    print(len(img_as_bytes))
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    s.bind(('0.0.0.0', 8585))
    s.listen(0)          

    client, addr = s.accept() # i'm pretty sure this block until the connection is made
                            # but that's good so we don't send all pictures at once i guess
    #print(img_as_bytes)
    print(len(img_as_bytes))
    client.sendall(img_as_bytes)
    client.close()

@app.route('/')
def index():
    return render_template("index.html")

def allowed_file(filename):
    fileVals = filename.split('.')
    extension = fileVals[-1].lower()
    if extension in ALLOWED_EXTENSIONS:
        return True
    return False

@app.route('/upload_print', methods=['GET', 'POST'])
def upload_print():
    if request.method == 'POST':
        file = request.files['file']
        if file.filename == '': # empty file
            flash("No selected file")
            return redirect(request.url)
        if file and allowed_file(file.filename):
            start = time.time()
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            flash("Successful Post!")
            t = threading.Thread(target=launchServer, args=(filename,))
            t.daemon = True
            t.start()
            end = time.time()
            print("Time elapsed: " + str(end-start))
            return redirect(url_for('upload_print', filename=filename))
        else:
            flash("Unsupported File: " + str(file.filename))
            flash("Supported formats are JPG, JPEG, PNG")
            return redirect(request.url)
    return render_template('print.html')


if __name__ == "__main__":
    # app.run(debug=True, ssl_context='adhoc')
    app.run(host='0.0.0.0', port=8000, debug=True)