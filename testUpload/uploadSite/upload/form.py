from django.db import models  
from django.forms import fields, Textarea
from .models import UploadImage  
from django import forms  
  
class UserImageForm(forms.ModelForm):  
    # Important: Very exact members (Meta, model) or the form's fields won't show up
    class Meta:  
        model = UploadImage  
        fields = "__all__"