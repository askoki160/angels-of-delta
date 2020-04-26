from django.conf.urls import include
from django.urls import path
from django.contrib import admin


urlpatterns = [
    path('game/', include('game.urls')),
    path('admin/', admin.site.urls),
]