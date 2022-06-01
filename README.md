# Mongodb-Compass 1.32 + OpenJDK Java 11 + Maven 3.8 + Python 3.8  + pip 21 + node 16 + npm 7 + Gradle 7

[![](https://images.microbadger.com/badges/image/openkbs/mongodb-compasss-docker.svg)](https://microbadger.com/images/openkbs/mongodb-compasss-docker "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/openkbs/mongodb-compasss-docker.svg)](https://microbadger.com/images/openkbs/mongodb-compasss-docker "Get your own version badge on microbadger.com")

# Components
* [Mongodb-Compass](https://docs.mongodb.com/compass) v 1.32.0 
* [Base Container Image: openkbs/jdk11-mvn-py3](https://github.com/DrSnowbird/jdk11-mvn-py3)
* [Base Components: OpenJDK, Python 3, PIP, Node/NPM, Gradle, Maven, etc.](https://github.com/DrSnowbird/jdk11-mvn-py3#components)
* Other tools: git wget unzip vim python python-setuptools python-dev python-numpy 

# Build (Do this First!)
```
make build
```

# Run
To bring up X-11 Desktop of Mongodb-Compass:
```
./run.sh
```

# Run with MongoDB together
You can run Compass DB GUI and local MongoDB (as test database)
1. Bring up 'mongodb-docker'
    ```
    docker-compose -f ./docker-compose up -d mongodb-docker
    ```
2. Use the Mongodb-Compass to connect to Mongodb-docker
The default password for local MongoDB:
    ```
    MONGO_INITDB_ROOT_USERNAME: mongoadmin
    MONGO_INITDB_ROOT_PASSWORD: mongoadmin
    ```
# (Optional) Run MongoDB with Mongo-Express (Web-based UI)
You can use both Mongodb-Compass (X11 Desktop App) and Mongo-Express (Web UI) at the same!
```
docker-compose up -d
```
Then, use your web-browser to go to:
```
http://0.0.0.0:28081/
(login/password: admin/changeme)
```
# References & Resources
* [**Mongodb Document**](https://docs.mongodb.com/)
* [Mongodb Compass (import/export)](https://docs.mongodb.com/compass/master/import-export/)

# See also
* [openkbs/mongo-docker](https://github.com/DrSnowbird/mongo-docker)
* [MySQL Workbench for MySQL Database Server Docker at openkbs/mysql-workbench](https://hub.docker.com/r/openkbs/mysql-workbench/)
* [Sqlectron SQL GUI at openkbs/sqlectron-docker](https://hub.docker.com/r/openkbs/sqlectron-docker/)
* [Mysql-Workbench at openkbs/mysql-workbench](https://hub.docker.com/r/openkbs/mysql-workbench/)
* [PgAdmin4 for PostgreSQL at openkbs/pgadmin-docker](https://hub.docker.com/r/openkbs/pgadmin-docker/)

