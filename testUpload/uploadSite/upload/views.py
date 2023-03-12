from django.shortcuts import render

# Create your views here.
from django.http import HttpResponse
from django.template import loader

from .form import UserImageForm
from .models import UploadImage  

from django.views.generic.base import TemplateView

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