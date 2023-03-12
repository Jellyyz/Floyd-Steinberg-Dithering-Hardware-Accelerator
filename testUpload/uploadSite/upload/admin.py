from django.contrib import admin
from .models import UploadImage

# Register your models here.
class uploadAdmin(admin.ModelAdmin):
    list_display = ["name", "image"]

admin.site.register(UploadImage, uploadAdmin)