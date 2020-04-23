import json
import random
from django.core.cache import cache
from channels.generic.websocket import AsyncWebsocketConsumer

cache.clear()

default_key = json.dumps({
    'players': [],
    'channel_ids': [],
    'current_player_turn': None
})


class MyStorage:
    current_player = None

    def __init__(self):
        pass

    def add_player(self, room_name, player_name, channel_id):
        session = json.loads(cache.get_or_set(room_name, default_key))
        player_dict = json.dumps({
            'position_index': 0,
            'name': player_name
        })
        session['players'].append(player_dict)
        session['channel_ids'].append(channel_id)
        print(session)
        cache.set(room_name, json.dumps(session))

    def get_all_data(self, room_name):
        return cache.get_or_set(room_name, default_key)

    def init_start_player(self, room_name):
        session = cache.get(room_name)
        if not session:
            # TODO: add error handling
            return

        data = json.loads(session)
        player_max = len(data.get('players', None))
        if not player_max or player_max == 0:
            # TODO: raise exception
            return
        self.current_player = random.randint(0, player_max - 1)
        data['current_player_turn'] = self.current_player
        cache.set(room_name, json.dumps(data))

    def update_player_position_index(self, room_name, channel_id, position_change_number):
        session = cache.get(room_name)
        if not session:
            # TODO: add error handling
            return

        data = json.loads(session)
        for idx, _id in enumerate(data['channel_ids']):
            if channel_id == _id:
                player_info = json.loads(data['players'][idx])
                player_info['position_index'] += int(position_change_number)
                print("Players position changed to: ", player_info['position_index'])
                data['players'][idx] = json.dumps(player_info)
                cache.set(room_name, json.dumps(data))

    def get_current_player_index(self):
        return self.current_player

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
                print('Deleted')
                return 

        print('Delete was not possible')


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
                        'start': json.dumps(storage.get_current_player_index())
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

    # Receive message from room group
    async def game_message(self, event):
        message = event['message']

        # Send message to WebSocket
        await self.send(text_data=message)