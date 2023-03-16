from django.shortcuts import render

from django.views.generic.base import TemplateView
from .models import DownloadImage
from django.conf import settings
from django.http import HttpResponse
from django.http import JsonResponse
import base64
import glob
import os
from PIL import Image, ImageOps

class DownloadView(TemplateView):
    template_name = 'download.html'
    #model = DownloadImage

    #def get_context_data(self, **kwargs: any) -> dict[str, any]:
    #    context = super().get_context_data(**kwargs)
    #    return context

def image_query(request):
    """
    Handle requests at xxx.xxx.xx.x/download/ for fetching an image.

    Poor security.
    """
    allowedExtensions = ("*.png", "*.jpg", "*.jpeg")
    list_of_files = glob.glob(settings.MEDIA_ROOT + "images\\*") # * -> all extensions allowed
    latest_file = max(list_of_files, key=os.path.getctime)
    latest_file_relative = "images\\" + latest_file.split('\\')[-1]

    context={'img':latest_file_relative}
    print(f"Fetch '{latest_file_relative}'") 
    return render(request, 'download.html', context)

def get_image(request):
    """
    Send over in request the base64 string of the "latest" file in to_be_dithered without preprocessing...
    """
    if request.method == "GET":
        allowedExtensions = ("*.png", "*.jpg", "*.jpeg")
        list_of_files = glob.glob(settings.MEDIA_ROOT + "images\\to_be_dithered\\*") # * -> all extensions allowed
        latest_file = max(list_of_files, key=os.path.getctime)
        latest_file_relative = settings.MEDIA_ROOT + "images\\to_be_dithered\\" + latest_file.split('\\')[-1]

        print(f"Fetch '{latest_file_relative}'")

        with open(latest_file_relative, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read())
        
        print(f"Sending over {encoded_string}")
        return HttpResponse(encoded_string, content_type='application/octet-stream')

def get_image_pre_process(request):
    """
    Send over in request the base64 string of the "latest" file in to_be_dithered 
    AFTER converting it to a grayscale .png file
    """
    if request.method == "GET":
        allowedExtensions = ("*.png", "*.jpg", "*.jpeg")
        list_of_files = glob.glob(settings.MEDIA_ROOT + "images\\to_be_dithered\\*") # * -> all extensions allowed
        latest_file = max(list_of_files, key=os.path.getctime)
        latest_file_relative = settings.MEDIA_ROOT + "images\\to_be_dithered\\" + latest_file.split('\\')[-1]


        original = Image.open(latest_file_relative)
        preprocessed_version = ImageOps.grayscale(original)
        preprocessed_path = settings.MEDIA_ROOT + "images\\to_be_dithered\\" + "___preprocessed____" + latest_file.split('\\')[-1]
        extension_index = preprocessed_path.rfind('.')
        preprocessed_path = preprocessed_path[0 : extension_index] + ".png"
        preprocessed_version.save(preprocessed_path, "PNG")

        
        print(f"Fetch '{latest_file_relative}' to preprocessed '{preprocessed_path}'")
        with open(preprocessed_path, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read())
        
        print(f"Sending over {encoded_string}")

        os.remove(preprocessed_path)
        return HttpResponse(encoded_string, content_type='application/octet-stream')