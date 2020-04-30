from django.core.cache import cache
from django.http import JsonResponse
from django.utils.crypto import get_random_string
from .data_storage import default_key

import logging
logger = logging.getLogger(__name__)

def room(request):
    room_key = get_random_string(length=4).lower()
    logger.info('Error happens even before')
    cache.set(room_key, default_key)
    logger.info(f'Setting room_key:{room_key} with value:{default_key}')
    return JsonResponse({'room_key': room_key})
