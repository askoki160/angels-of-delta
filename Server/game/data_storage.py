import json
import random
from typing import Union
from django.core.cache import cache

default_key = json.dumps({
    'players': [],
    'channel_ids': [],
    'current_player_turn': None
})

class GameDataStorage:
    start_player_id = 0

    def __init__(self):
        pass

    @staticmethod
    def add_player(room_name, player_name, channel_id) -> None:
        session = json.loads(cache.get_or_set(room_name, default_key))
        player_dict = json.dumps({
            'position_index': 0,
            'name': player_name
        })
        session['players'].append(player_dict)
        session['channel_ids'].append(channel_id)
        print(session)
        cache.set(room_name, json.dumps(session))

    @staticmethod
    def get_all_data(room_name) -> json:
        return cache.get_or_set(room_name, default_key)

    def init_start_player(self, room_name) -> None:
        session = cache.get(room_name)
        if not session:
            # TODO: add error handling
            return

        data = json.loads(session)
        player_max = len(data.get('players', None))
        if not player_max or player_max == 0:
            # TODO: raise exception
            return
        data['current_player_turn'] = random.randint(0, player_max - 1)
        self.start_player_id = data['current_player_turn']
        cache.set(room_name, json.dumps(data))

    @staticmethod
    def update_player_position_index(room_name, channel_id, position_change_number) -> None:
        session = cache.get(room_name)
        if not session:
            # TODO: add error handling
            return

        data = json.loads(session)
        for idx, _id in enumerate(data['channel_ids']):
            if channel_id == _id:
                player_info = json.loads(data['players'][idx])
                if position_change_number == 'reset':
                    player_info['position_index'] = 0
                else:
                    position_change_number = int(position_change_number)
                    player_info['position_index'] = (player_info['position_index'] + position_change_number) % 30
                print(f'Player {player_info["name"]} position changed to: {player_info["position_index"]}')
                data['players'][idx] = json.dumps(player_info)
                cache.set(room_name, json.dumps(data))

    @staticmethod
    def update_current_player_turn(room_name, next_player_index) -> None:
        session = cache.get(room_name)
        if not session:
            # TODO: add error handling
            return

        data = json.loads(session)
        data['current_player_turn'] = int(next_player_index)
        cache.set(room_name, json.dumps(data))

    def get_start_player_id(self) -> int:
        return self.start_player_id

    @classmethod
    def get_player_index(self, room_name, channel_id) -> Union[int, None]:
        session = cache.get(room_name)
        if not session:
            # TODO: add error handling
            return

        data = json.loads(session)
        for idx, _id in enumerate(data['channel_ids']):
            if channel_id == _id:
                return idx
        return None

    def remove_player(self, room_name, channel_id) -> None:
        session = cache.get(room_name)
        if not session:
            # TODO: add error handling
            return

        data = json.loads(session)
        player_index = self.get_player_index(room_name, channel_id)
        if player_index is not None:
            del data['players'][player_index]
            del data['channel_ids'][player_index]
            cache.set(room_name, json.dumps(data))
            print('Deleted')
            return
        print('Delete was not possible ', player_index)
        print(data)
