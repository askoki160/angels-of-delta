## Server development

1. make sure redis server is running:

    `sudo service redis-server status`

2. Create virtual env in root folder:

    `python3 -m venv env`

3. Activate environment

    `source env/bin/activate`

4. Install server requirements:

    `pip install -r Server/requirements.txt`

5. Start Server with: 

    `python manage.py runserver`

6. In `/Godot/` create `.env_secrets.gd` file from `.env_secrets.example.gd` and define variables.

7. Export Godot project as HTML5 inside `/Godot/exports`

8. Serve content of `/Godot/exports` e.g.

    `python -m SimpleHTTPServer 8090`

9. Make sure that address on which content is served is the same as one in default `CORS_ORIGIN_WHITELIST` setting inside
`Server/angels_of_delta_server/settings.py`. 
If that is not the case, server won't allow any requests from the client.

## Run development in docker 

##### Useful when developing only client funcionality

1. In `/Godot/` create `.env_secrets.gd` file from `.env_secrets.example.gd` and define variables.
 
2. Make sure that Godot app is exported in `/Godot/exports`

3. In `/conf/docker-compose/envs` create `.env` file from `.env.example` and define variables.

4. In `/conf/Server/env` create `dev_env.sh` file from `dev_env.example.sh` and define variables.

5. Run app

    `cd cli/`
    
    `./start_dev.sh`

6. Stop app:

    `cd cli/`
    
    `./stop_dev.sh`

## Run prod in docker

1. In `/Godot/` create `.env_secrets.gd` file from `.env_secrets.example.gd` and define variables.
 
2. Make sure that Godot app is exported in `/Godot/exports`

3. In `/conf/docker-compose/envs` create `.env` file from `.env.example` and define variables.

4. In `/conf/Server/env` create `prod_env.sh` file from `prod_env.example.sh` and define variables.

5. Run production

    `cd cli/`
    
    `./build_prod.sh`

6. Stop production

    `cd cli/`
    
    `./stop_prod.sh`




