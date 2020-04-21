import json
from django.core.cache import cache
from channels.generic.websocket import AsyncWebsocketConsumer

cache.clear()

default_key = json.dumps({
    'players': [],
    'channel_ids': []
})


class MyStorage:

    def __init__(self):
        pass

    def add_player(self, room_name, player, channel_id):
        session = json.loads(cache.get_or_set(room_name, default_key))
        session['players'].append(player)
        session['channel_ids'].append(channel_id)
        cache.set(room_name, json.dumps(session))

    def get_all_data(self, room_name):
        return cache.get_or_set(room_name, default_key)

    def remove_player(self, room_name, channel_id):
        session = cache.get(room_name)
        if not session:
            # TODO: add error handling
            return

        data = json.loads(session)
        for idx, _id in enumerate(data['channel_ids']):
            if channel_id == _id:
                del data['players'][idx]
                del data['channel_ids'][idx]
                cache.set(room_name, json.dumps(data))
                print("Deleted")
                return 

        print("Dele was not possible")


storage = MyStorage()


class GameConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_name = self.scope['url_route']['kwargs']['room_name']
        self.room_group_name = 'game_%s' % self.room_name

        exists = cache.get(self.room_name)
        if exists:
            # Join room group
            await self.channel_layer.group_add(
                self.room_group_name,
                self.channel_name
            )

            await self.accept()

    async def disconnect(self, close_code):
        storage.remove_player(self.channel_name)
        # Leave room group
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )
        # Update players in a lobby
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'game_message',
                'message': json.dumps(storage.get_all_data(self.room_name))
            }
        )

    # Receive message from WebSocket
    async def receive(self, bytes_data):
        decoded_input = json.loads(bytes_data.decode("utf-8"))
        if decoded_input["name"] != "":
            storage.add_player(self.room_name, decoded_input["name"], self.channel_name)
            # Send message to room group
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'game_message',
                    'message': json.dumps(storage.get_all_data(self.room_name))
                }
            )

    # Receive message from room group
    async def game_message(self, event):
        message = event['message']

        # Send message to WebSocket
        await self.send(text_data=message)
