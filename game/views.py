from django.shortcuts import render


def index(request):
    return render(request, 'game/index.html')


def room(request, room_name):
    return render(request, 'game/room.html', {
        'room_name': room_name
    })
