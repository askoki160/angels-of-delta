import json
class MyStorage:

    def __init__(self):
        self.players = []

    def add_player(self, player):
        self.players.append(player)

    def get_all_players(self):
        return self.players


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