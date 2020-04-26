from django.urls import path

from . import views

urlpatterns = [
    path('get-room/', views.room, name='room'),
]