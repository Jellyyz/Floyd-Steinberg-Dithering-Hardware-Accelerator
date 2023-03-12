from django.db import models

class DownloadImage(models.Model):
    name = models.CharField(max_length = 200)  
    image = models.ImageField()

    def save(self):
        super(DownloadImage, self).save()
  
    def __str__(self):  
        return self.name  
