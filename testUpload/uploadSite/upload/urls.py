from django.urls import path

from . import views

app_name = "upload"
urlpatterns = [
    path('', views.IndexView.as_view(), name = "index"),
    path('req/', views.image_request, name = "image_request"),
    path('mcu_upload/', views.mcu_upload, name = "mcu_upload"),
    path('mcu_upload_param/', views.mcu_upload_param, name = "mcu_upload_param"),
]