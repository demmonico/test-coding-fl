# Test coding

### Task

Design and implement a *high available[\[1\]](#1-high-available)* infrastructure with Docker and Docker Compose similar
to the sketch below.

```
                             +----------+                    +----------+
                             |          |                    |          |
                             |    FE    |                    |    BE    |
                            /|          |\                  /|          |\
                           / +----------+ \                / +----------+ \
             +----------+ /                \ +----------+ /                \ +----------+
 http/https  |          |/                  \|          |/                  \|          |
>------------|    LB    |                    |    LB    |                    |    DB    |
             |          |\                  /|          |\                  /|          |
             +----------+ \                / +----------+ \                / +----------+
                           \ +----------+ /                \ +----------+ /
                            \|          |/                  \|          |/
                             |    FE    |                    |    BE    |
                             |          |                    |          |
                             +----------+                    +----------+
```

##### Required functionality:

* You need to have at least two FE's[\[2\]](#2-fe)
* You need to have at least two BE's[\[3\]](#3-be)
* Database must have persistant storage
* Host OS must be able to access the application via http or https

##### Technical constraints:

* You can make use of official Docker images
* [FE](data/fe/) and [BE](data/be/) applications as well as MySQL [dummy data](data/sql/) is provided
* Provide a working `docker-compose.yml` and instructions how to get the setup running

##### Bonus points

* Provide a way to show container metrics
* Have separate networks with least required access
* Have unlimited FE's and BE's and make LB's autodiscover them

##### Outstanding bonus points

* For local development, have syncronized file and directory permissions between container and host os[\[4\]](#4-syncronized-permissions)

---

##### Notes

###### \[1\] High-available

Load Balancer's itself are just for demonstration purposes and don't need to be high available or
redundant in your implementation.

###### \[2\] FE

FE refers to the front end and is provided within this repository ([code-fe](code-fe) folder).

###### \[3\] BE

BE refers to the back end and is provided within this repository ([code-be](code-be) folder).

###### \[4\] Syncronized permissions

When using this setup as a local development stack, you don't want to start it up as root, but
rather as your local user. Additionally you want to have FE and BE data mounted to you host operating
system, so you can edit files with your IDE/editor.

With this in mind, you need to ensure that permissions of files and directories created on your host
machine can still be edited or deleted inside the container by its running service.

Vice-versa saying, any files created within the container should still be editable or deletable on
your host operating system by your local user.

### Solution

Well, basically this repo is solution. FE's and BE's codes placed here also.

##### Run

```shell script
docker-compose up
```

Now it accessible as `http://localhost:8080` and `https://localhost:8443`. And
- there are 2 FE, 2 BE
- DB files placed at the `infra/local/mysql/data` folder

Cheers!

Ah, yeah...

##### Additionals

- `Provide a way to show container metrics` - Maybe `docker stats $(docker-compose ps -q)` would be enough for local machine? ;)
```shell script
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
221197aaf640        fl_app_be_1         0.01%               20.61MiB / 1.945GiB   1.04%               48kB / 47.2kB       0B / 0B             21
f3b1211a775d        fl_app_be_2         0.04%               20.57MiB / 1.945GiB   1.03%               49.8kB / 48.8kB     0B / 0B             21
18a8b73cf52f        fl_app_db_1         0.79%               328.5MiB / 1.945GiB   16.50%              47.1kB / 48.1kB     0B / 8.19kB         38
68f349b596f8        fl_app_fe_1         0.01%               18.68MiB / 1.945GiB   0.94%               76kB / 38.4kB       0B / 0B             21
179040c3484e        fl_app_fe_2         0.05%               18.78MiB / 1.945GiB   0.94%               75.6kB / 38.2kB     0B / 0B             21
2b0f84618651        fl_app_fe_3         0.01%               13.02MiB / 1.945GiB   0.65%               3.84kB / 1.52kB     0B / 0B             21
1c96358ac870        fl_app_nginx_be_1   0.00%               2.129MiB / 1.945GiB   0.11%               75.9kB / 101kB      0B / 0B             2
9aa13fafe263        fl_app_nginx_fe_1   0.00%               2.449MiB / 1.945GiB   0.12%               138kB / 160kB       0B / 0B             2
```

- `Have separate networks with least required access` - Done - there are 3 networks: `default`, `frontend` and `backend`
```shell script
$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
ea1eb2d6be40        fl_backend          bridge              local
695cd9f4d18d        fl_default          bridge              local
125020a532b8        fl_frontend         bridge              local
 
$ docker network inspect -f '{{ range $key, $value := .Containers }}{{printf "%s\n" .Name}}{{ end }}' fl_default
fl_app_nginx_fe_1
 
$ docker network inspect -f '{{ range $key, $value := .Containers }}{{printf "%s\n" .Name}}{{ end }}' fl_frontend
fl_app_fe_2
fl_app_nginx_be_1
fl_app_fe_1
fl_app_nginx_fe_1
 
$ docker network inspect -f '{{ range $key, $value := .Containers }}{{printf "%s\n" .Name}}{{ end }}' fl_backend
fl_app_db_1
fl_app_nginx_be_1
fl_app_be_1
fl_app_be_2
```

- `Have unlimited FE's and BE's and make LB's autodiscover them` - Hmm again, it's not `autodiscover`, but still you can do:
```shell script
# scale for example app_fe service
docker-compose scale app_fe=3
 
# reload nginx config to let it be autodiscovered
docker exec -ti fl_app_nginx_fe_1 nginx -s reload
``` 

- `... syncronized file and directory permissions between container and host os` - basically, 
I'd like to do it with configure user ID inside container (e.g. `www-data` user for Apache) 
equal to user ID which is running `docker-compose up` (usually it's kind of `1000`). 
Let's say at the entrypoint to each container (unique by service) to run at the very first container's run:
```shell script
usermod -u ${HOST_USER_ID} www-data && groupmod -g ${HOST_USER_ID} www-data
```

