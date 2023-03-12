from django.urls import path

from . import views

app_name = "upload"
urlpatterns = [
    path('', views.IndexView.as_view(), name="index"),
    path('req/', views.image_request, name = "image_request"),
]