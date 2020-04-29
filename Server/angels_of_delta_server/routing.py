from channels.routing import ProtocolTypeRouter, URLRouter
import game.routing

application = ProtocolTypeRouter({
    # (http->django views is added by default)
    'websocket': URLRouter(
        game.routing.websocket_urlpatterns
    )
})
