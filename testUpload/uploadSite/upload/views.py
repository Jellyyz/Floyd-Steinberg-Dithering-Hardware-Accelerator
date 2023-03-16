from django.shortcuts import render

# Create your views here.
from django.http import HttpResponse
from django.template import loader

from .form import UserImageForm
from .models import UploadImage  

from django.views.generic.base import TemplateView
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings
import numpy as np
from PIL import Image
import os

w = -1
h = -1

class IndexView(TemplateView):
    template_name = 'index.html'
  
def image_request(request):
    """
    Handle requests at xxx.xxx.xx.x/upload/req/
    """
    if request.method == 'POST':  
        form = UserImageForm(request.POST, request.FILES)  
        if form.is_valid():  
            form.save()  
  
            img_object = form.instance  
              
            return render(request, 'index.html', {'form': form, 'img_object': img_object})
        else:
            print(form.errors_as_data())
    else:  
        form = UserImageForm()  
  
    return render(request, 'index.html', {'form': form})  

@csrf_exempt
def mcu_upload(request):
    """
    Handles request at xxx.xxx.xx.x/upload/mcu_upload/

    f(Text) => Upload .png to server as "test.png" using the received `w` and `h` 
    """
    global w
    global h
    if request.method == 'POST':
        print(f"Image received ({w} x {h})...")
        byte_arr = np.frombuffer(request.body, dtype = np.ubyte)
        print(f"Buffer shape?: {byte_arr.shape}")
        byte_arr = byte_arr.reshape(h, w)
        received_img = Image.fromarray(byte_arr)
        received_img.save(os.path.join(settings.MEDIA_ROOT, 'images\\dithered\\test.png'))
        print("Uploaded as test.png")

        
        return HttpResponse(content_type='application/json', status = 200)
    return HttpResponse(content_type='application/json', status = 400)

@csrf_exempt
def mcu_upload_param(request):
    """
    Handles request at xxx.xxx.xx.x/upload/mcu_upload_param/

    f("w,h") => Store width and height of target upload (called before mcu_upload)
    """
    global w
    global h
    if request.method == 'POST':
        print("mcu_upload_param <= ", request.body.decode('utf-8'))
        params = request.body.decode('utf-8').split(',')
        w = int(params[0])
        h = int(params[1])

        print(f"w <= {w} && h <= {h}")

        return HttpResponse(content_type='application/json', status = 200)
    return HttpResponse(content_type='application/json', status = 400)