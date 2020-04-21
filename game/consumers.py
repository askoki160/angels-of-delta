import json
from django.core.cache import cache
from channels.generic.websocket import AsyncWebsocketConsumer

# cache.clear()

default_key = json.dumps({
    'players': []
})


class MyStorage:

    def __init__(self):
        pass

    def add_player(self, player):
        session = json.loads(cache.get_or_set('session', default_key))
        session['players'].append(player)
        cache.set('session', json.dumps(session))
        print(session)

    def get_all_players(self):
        return cache.get_or_set('session', default_key)


storage = MyStorage()

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_name = self.scope['url_route']['kwargs']['room_name']
        self.room_group_name = 'chat_%s' % self.room_name

        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()

    async def disconnect(self, close_code):
        # Leave room group
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    # Receive message from WebSocket
    async def receive(self, bytes_data):
        decoded_input = json.loads(bytes_data.decode("utf-8"))
        if decoded_input["name"] != "":
            storage.add_player(decoded_input["name"])
            # Send message to room group
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'chat_message',
                    'message': json.dumps(storage.get_all_players())
                }
            )

    # Receive message from room group
    async def chat_message(self, event):
        message = event['message']

        # Send message to WebSocket
        await self.send(text_data=message)
