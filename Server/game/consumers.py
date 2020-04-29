import json
from django.core.cache import cache
from .data_storage import GameDataStorage
from channels.generic.websocket import AsyncWebsocketConsumer

storage = GameDataStorage()

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
        storage.remove_player(self.room_name, self.channel_name)
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
        decoded_input = json.loads(bytes_data.decode('utf-8'))

        # player joins lobby
        if decoded_input.get('name', '') != '':
            storage.add_player(self.room_name, decoded_input['name'], self.channel_name)
            # Send message to room group
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'game_message',
                    'message': json.dumps(storage.get_all_data(self.room_name))
                }
            )

        # start game
        if decoded_input.get('start', False):
            storage.init_start_player(self.room_name)
            # Update players in a lobby
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'game_message',
                    'message': json.dumps({
                        'start_player': json.dumps(storage.get_start_player_id())
                    })
                }
            )

        # update player state
        if decoded_input.get('info', False):
            storage.update_player_position_index(self.room_name, self.channel_name, decoded_input.get('info'))
            # Update players in a lobby
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'game_message',
                    'message': json.dumps(storage.get_all_data(self.room_name))
                }
            )

        # update player state
        if decoded_input.get('turn_ended', False):
            storage.update_current_player_turn(self.room_name, decoded_input.get('turn_ended'))
            # update index of the next player
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'game_message',
                    'message': json.dumps({
                        'active_player': json.dumps(decoded_input.get('turn_ended'))
                    })

                }
            )

    # Receive message from room group
    async def game_message(self, event):
        message = event['message']

        # Send message to WebSocket
        await self.send(text_data=message)
