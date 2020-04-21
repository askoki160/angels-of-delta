from django.shortcuts import render
from django.http import JsonResponse
from django.utils.crypto import get_random_string


def room(request):
    room_key = get_random_string(length=4)
    return JsonResponse({'room_key': room_key})