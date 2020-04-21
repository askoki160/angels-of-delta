from django.conf.urls import url, include
from django.urls import path
from django.contrib import admin


urlpatterns = [
    path('chat/', include('game.urls')),
    path('admin/', admin.site.urls),
]