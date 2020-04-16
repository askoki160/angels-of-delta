from django.core.cache import cache
import json

default_key = json.dumps([{
    'players': []
}])

class MyStorage:

    def __init__(self):
        pass

    def add_player(self, player):
        session = json.loads(cache.get_or_set('session', default_key))
        session[0]['players'].append(player)
        cache.set('session', json.dumps(session))

    def get_all_players(self):
        return cache.get_or_set('session', default_key)


async def websocket_application(scope, receive, send):
    storage = MyStorage()
    while True:
        event = await receive()

        if event['type'] == 'websocket.connect':
            await send({
                'type': 'websocket.accept'
            })

        if event['type'] == 'websocket.disconnect':
            break

        if event['type'] == 'websocket.receive':
            print(event)
            if 'text' in event and event['text'] == 'ping':
                await send({
                    'type': 'websocket.send',
                    'text': 'pong!'
                })

            if not 'bytes' in event:
                continue

            decoded_input = event['bytes'].decode("utf-8")
            if decoded_input  == 'ping':
                print("Sent")
                await send({
                    'type': 'websocket.send',
                    'bytes': 'pong!'
                })
            else:
                decoded_input = json.loads(decoded_input)
                storage.add_player(decoded_input["name"])
                await send({
                    'type': 'websocket.send',
                    'bytes': json.dumps(storage.get_all_players())
                })