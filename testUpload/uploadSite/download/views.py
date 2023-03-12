from django.shortcuts import render

from django.views.generic.base import TemplateView
from .models import DownloadImage
from django.conf import settings
from django.http import HttpResponse
from django.http import JsonResponse
import base64
import glob
import os

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
    if request.method == "GET":
        allowedExtensions = ("*.png", "*.jpg", "*.jpeg")
        list_of_files = glob.glob(settings.MEDIA_ROOT + "images\\*") # * -> all extensions allowed
        latest_file = max(list_of_files, key=os.path.getctime)
        latest_file_relative = settings.MEDIA_ROOT + "images\\" + latest_file.split('\\')[-1]

        print(f"Fetch '{latest_file_relative}'")

        with open(latest_file_relative, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read())
        
        print(f"Sending over {encoded_string}")
        return HttpResponse(encoded_string, content_type='application/octet-stream')