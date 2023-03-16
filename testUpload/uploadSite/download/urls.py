from django.urls import path

from . import views

app_name = "download"
urlpatterns = [
    path('', views.DownloadView.as_view(), name="index"),
    path('image_query', views.image_query, name="image_query"),
    path('get_image', views.get_image_pre_process, name="get_image"),
]