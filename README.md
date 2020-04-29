# angels-of-delta-server

install requirements:

`pip install -r requirements.txt`


## Development

make sure redis server is running:

`sudo service redis-server status`

start Server with: 

`python manage.py runserver`

export Godot project as HTML5 inside /Godot/exports

Serve content of /Godot/exports e.g. `python -m SimpleHTTPServer 8080`

## Run dev in docker

`cd conf`
`docker-compose up`





