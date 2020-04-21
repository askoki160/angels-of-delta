"""
ASGI config for angels_of_delta_server project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/3.0/howto/deployment/asgi/
"""

import os

from django.core.asgi import get_asgi_application
from .websocket import websocket_application


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'angels_of_delta_server.settings')

application = get_asgi_application()