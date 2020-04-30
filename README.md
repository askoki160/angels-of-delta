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
Create dev_env.sh from dev_env.example.sh and define variables.

`cd conf/development`
`docker-compose -p delta up`

## Run prod in docker
Create prod_env.sh from prod_env.example.sh and define variables.

`cd conf/production`
`docker-compose -p delta up`




